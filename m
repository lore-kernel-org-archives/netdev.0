From: Ramesh Nagappa <ramesh.nagappa@ericsson.com>
Subject: RE: [PATCH] net: fix neigh_resolve_output can cause skb_under_panic
Date: Fri, 28 Sep 2012 20:26:51 -0400
Message-ID: <CA3E5132752D1F49871ED0FC40D56BBA43ECE2E743@EUSAACMS0701.eamcs.ericsson.se>
References: <CA3E5132752D1F49871ED0FC40D56BBA43ECE2E72D@EUSAACMS0701.eamcs.ericsson.se>
 <20120928235209.GA11474@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"michel@digirati.com.br" <michel@digirati.com.br>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120928235209.GA11474@kroah.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> Why is all of this in the middle of the changelog section?
> 
> I'm guessing you didn't use 'git send-email' for this?
> 
> And why are you copying me on the patch?

I got the CC list from scripts/get_maintainers.pl

asglx-2-300 $ scripts/get_maintainer.pl 0001-net-fix-neigh_resolve_output-can-cause-skb_under_pan.patch
"David S. Miller" <davem@davemloft.net> (maintainer:NETWORKING [GENERAL],commit_signer:3/4=75%)
Greg Kroah-Hartman <gregkh@linuxfoundation.org> (commit_signer:3/4=75%)
Eric Dumazet <eric.dumazet@gmail.com> (commit_signer:2/4=50%)
Shawn Lu <shawn.lu@ericsson.com> (commit_signer:1/4=25%)
Michel Machado <michel@digirati.com.br> (commit_signer:1/4=25%)
netdev@vger.kernel.org (open list:NETWORKING [GENERAL])
linux-kernel@vger.kernel.org (open list)

> 
> 
> You need a blank line before the first Signed-off-by: line.  
> Surely one of the reviewers should have caught this basic thing?

Outlook mangled the patch. I am unable to use git send-email because of
a corporate firewall on the build machine.

> 
> greg k-h
> 

Thanks,
Ramesh