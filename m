From: Xi Wang <xi.wang@gmail.com>
Subject: Re: [PATCH RESEND] sctp: fix incorrect overflow check on autoclose
Date: Wed, 14 Dec 2011 16:35:38 -0500
Message-ID: <95EC5F1E-B23C-48E1-B9F7-0B7656D75DC0@gmail.com>
References: <1323393883-3759-1-git-send-email-xi.wang@gmail.com> <4EE2478B.5010409@hp.com> <8EEC521A-CA38-4CE9-BCFD-BA6FC9A85D18@gmail.com> <4EE67DC6.3000500@hp.com> <702540E4-9FD3-4B71-B53A-FE5D4323A898@gmail.com> <4EE7CE80.9050307@hp.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Andrei Pelinescu-Onciul <andrei@iptel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Vladislav Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:44650 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755092Ab1LNVfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 16:35:45 -0500
In-Reply-To: <4EE7CE80.9050307@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 13, 2011, at 5:15 PM, Vladislav Yasevich wrote:
> I agree, this is ugly.  It might make more sense to define a max autoclose
> value and expose it through /sys.  That way the values remains consistent.

Hmm, this sounds nice.  I will give it a try in v2. 

- xi
