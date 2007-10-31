From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 00/33] Swap over NFS -v14
Date: Wed, 31 Oct 2007 14:26:32 +1100
Message-ID: <200710311426.33223.nickpiggin@yahoo.com.au>
References: <20071030160401.296770000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp106.mail.mud.yahoo.com ([209.191.85.216]:48347 "HELO
	smtp106.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751487AbXJaEdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 00:33:16 -0400
In-Reply-To: <20071030160401.296770000@chello.nl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 31 October 2007 03:04, Peter Zijlstra wrote:
> Hi,
>
> Another posting of the full swap over NFS series.

Hi,

Is it really worth all the added complexity of making swap
over NFS files work, given that you could use a network block
device instead?

Also, have you ensured that page_file_index, page_file_mapping
and page_offset are only ever used on anonymous pages when the
page is locked? (otherwise PageSwapCache could change)
