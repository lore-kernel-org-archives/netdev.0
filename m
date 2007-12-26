From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ipv4: Update ip command line processing (take II)
Date: Tue, 25 Dec 2007 20:55:43 -0800 (PST)
Message-ID: <20071225.205543.240106823.davem@davemloft.net>
References: <20071226025903.GB14422@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	apw@us.ibm.com
To: horms@verge.net.au
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752499AbXLZE4D@vger.kernel.org>
In-Reply-To: <20071226025903.GB14422@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>
Date: Wed, 26 Dec 2007 11:59:05 +0900

> Recently the documentation in Documentation/nfsroot.txt was
> update to note that in fact ip=off and ip=::::::off as the
> latter is ignored and the default (on) is used.
> 
> This was certainly a step in the direction of reducing confusion.
> But it seems to me that the code ought to be fixed up so that
> ip=::::::off actually turns off ip autoconfiguration.
> 
> This patch also notes more specifically that ip=on (aka ip=::::::on)
> is the default.
> 
> Cc: Amos Waterland <apw@us.ibm.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>

I applied this to net-2.6 since I think it's a bug fix, and
I also tailored the changelog header to more it clear this
is a fix not just an "Update". :-)

Thanks!

