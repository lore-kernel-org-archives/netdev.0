From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [net-next patch v2] bnx2x: Add run-time CNIC support
Date: Tue, 10 Jul 2012 15:41:29 +0300
Message-ID: <1341924089.27035.7.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1341922620.27284.16.camel@lb-tlvb-meravs.il.broadcom.com>
 <20120710.052149.792836375666491854.davem@davemloft.net>
 <1341923634.27035.6.camel@lb-tlvb-eilong.il.broadcom.com>
 <20120710.053724.1002197670026212780.davem@davemloft.net>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: meravs@broadcom.com, netdev@vger.kernel.org, dmitry@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2469 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755396Ab2GJMlm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 08:41:42 -0400
In-Reply-To: <20120710.053724.1002197670026212780.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-10 at 05:37 -0700, David Miller wrote:
> From: "Eilon Greenstein" <eilong@broadcom.com>
> Date: Tue, 10 Jul 2012 15:33:54 +0300
> 
> > On Tue, 2012-07-10 at 05:21 -0700, David Miller wrote:
> >> Make it really dynamic, and properly configurable at run time, so
> >> people don't have to go through hoops to get the "advantages" you
> >> speak so highly of.
> > 
> > This is possible for the resources, but not for the latency - we cannot
> > change the HW mode once traffic started to run. Why is that so bad to
> > support Kconfig as a working mode like we did thus far? We are using it
> > specifically for users that wants to optimize the kernel, so Kconfig
> > does not sound that bad in that context.
> 
> Sure you can find a way to make this work, you just really aren't
> trying hard enough.
> 
> The current situation is a huge and gross hack.  I'm not letting you
> continue spreading this disease.
> 
> Implement this properly, I really mean it.
> 

OK. Since it blocks the ability to add SR-IOV support, is it acceptable
to submit it as constant enabled for PF and disabled for VF (SR-IOV)?
