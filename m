From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net/netfilter: simplify error handling
Date: Fri, 05 Dec 2008 16:22:22 +0100
Message-ID: <4939472E.7060804@trash.net>
References: <Pine.LNX.4.64.0812051234230.9560@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756806AbYLEPWk@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0812051234230.9560@pc-004.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> nf_conntrack_alloc cannot return NULL, so there is no need to check for
> NULL before using the value.  I have also removed the initialization of ct
> to NULL in nf_conntrack_alloc, since the value is never used, and since
> perhaps it might lead one to think that return ct at the end might return
> NULL.

Applied, thanks.
