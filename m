From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 06/33] mm: allow PF_MEMALLOC from softirq context
Date: Wed, 31 Oct 2007 14:51:56 +1100
Message-ID: <200710311451.56747.nickpiggin@yahoo.com.au>
References: <20071030160401.296770000@chello.nl> <20071030160911.540148000@chello.nl>
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
Received: from smtp108.mail.mud.yahoo.com ([209.191.85.218]:25088 "HELO
	smtp108.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751540AbXJaE6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 00:58:36 -0400
In-Reply-To: <20071030160911.540148000@chello.nl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 31 October 2007 03:04, Peter Zijlstra wrote:
> Allow PF_MEMALLOC to be set in softirq context. When running softirqs from
> a borrowed context save current->flags, ksoftirqd will have its own
> task_struct.


What's this for? Why would ksoftirqd pick up PF_MEMALLOC? (I guess
that some networking thing must be picking it up in a subsequent patch,
but I'm too lazy to look!)... Again, can you have more of a rationale in
your patch headers, or ref the patch that uses it... thanks

