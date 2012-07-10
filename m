From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [net-next patch v2] bnx2x: Add run-time CNIC support
Date: Tue, 10 Jul 2012 15:33:54 +0300
Message-ID: <1341923634.27035.6.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1341828055-4467-1-git-send-email-meravs@broadcom.com>
 <20120709.141010.996787793429264956.davem@davemloft.net>
 <1341922620.27284.16.camel@lb-tlvb-meravs.il.broadcom.com>
 <20120710.052149.792836375666491854.davem@davemloft.net>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: meravs@broadcom.com, netdev@vger.kernel.org, dmitry@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4281 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751568Ab2GJMeE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 08:34:04 -0400
In-Reply-To: <20120710.052149.792836375666491854.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-10 at 05:21 -0700, David Miller wrote:
> From: "Merav Sicron" <meravs@broadcom.com>
> Date: Tue, 10 Jul 2012 15:17:00 +0300
> 
> > There are still two advantages in disabling CNIC in bnx2x: Saving
> > resources (MSI-X vector and memory) as well as reducing some latency.
> 
> But, nobody does this.  No end user can do this easily, this
> is therefore of zero value to him.

Most do not, but I'm aware of two customers that play with their own
kernel that do that - they can play with the driver and tweak it to
disable this mode manually, but that is similar to supporting something
outside the tree.

> > While it is true that distributions enable the CNIC Kconfig option, some
> > users that care about resources and latency compile a kernel without it.
> 
> This, therefore, results in a terrible user experience.

We are using the Kconfig since it is meant for advanced users that
customize their kernel to their needs.

> > Can you please re-consider this patch?
> 
> Absolutely not.
> 
> Make it really dynamic, and properly configurable at run time, so
> people don't have to go through hoops to get the "advantages" you
> speak so highly of.

This is possible for the resources, but not for the latency - we cannot
change the HW mode once traffic started to run. Why is that so bad to
support Kconfig as a working mode like we did thus far? We are using it
specifically for users that wants to optimize the kernel, so Kconfig
does not sound that bad in that context.
