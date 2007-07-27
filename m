From: Glen Gray <glen@lincor.com>
Subject: Re: Multicast issues with RTL8110SC in r8169.c
Date: Fri, 27 Jul 2007 09:13:29 +0100
Message-ID: <46A9A929.7020605@lincor.com>
References: <F5A04EB7-0726-4CF5-A4B8-F32F00D9BC52@lincor.com> <20070718221107.GE9755@electric-eye.fr.zoreil.com> <46A84E59.6010803@lincor.com> <20070726213020.GB14306@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.station1.mxsweep.com ([212.147.136.149]:2634 "EHLO
	2out.mxsweep.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1761190AbXG0INk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2007 04:13:40 -0400
In-Reply-To: <20070726213020.GB14306@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Glen Gray <glen@lincor.com> :
>> Hey Francois,
>> I've CC'd the netdev list as requested
> 
> Your PR is not lost (nor are the pending ones btw...). I'm simply trying
> to find a real explanation for
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=242572
> 

Ah, apologies. When I couldn't see my follow up posts hitting the list, 
I figured I'd sign up and post it again.

The linked bug entry indicates issues with the driver initializing 
certain cards etc. As previously stated, my issue was mainly in 
multicast. I was able to get the machine up and on the network without 
issue in the 2.6.21 kernel from F7. Though there's obviously issues with 
the newer Realtek cards and the post 2.6.20 kernels.

FYI, The Realtek driver release 1.06 (r1000.ko), although not officially 
supporting the 2.6 kernel (the Makefile just needed modification) works 
extremely well for us here.

If I can help test experimental patchs or anything, please don't 
hesitate to let me know.
-- 
Glen Gray <glen@lincor.com>              Digital Depot, Thomas Street
Senior Software Engineer                            Dublin 8, Ireland
Lincor Solutions Ltd.                          Ph: +353 (0) 1 4893682
