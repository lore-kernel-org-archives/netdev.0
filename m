From: "Rune Torgersen" <runet@innovsys.com>
Subject: RE: WARN_ON() hit in fsl bitbanged phy driver
Date: Mon, 11 Feb 2008 16:12:34 -0600
Message-ID: <DCEAAC0833DD314AB0B58112AD99B93B03F9325F@ismail.innsys.innovsys.com>
References: <DCEAAC0833DD314AB0B58112AD99B93B03F931E6@ismail.innsys.innovsys.com> <47B0C30A.1030801@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linuxppc-dev@ozlabs.org>, <netdev@vger.kernel.org>
To: "Scott Wood" <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.innovsys.com ([66.115.232.196]:34561 "EHLO
	mail.innovsys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757260AbYBKWMj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 17:12:39 -0500
Content-class: urn:content-classes:message
In-Reply-To: <47B0C30A.1030801@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Wood wrote:
> Rune Torgersen wrote:
>> I hit the following WARN_ON when using mii-tools agains a ethernet
>> interface using a bit-banged mii interface
> 
> It looks like the kernel thinks it's in an interrupt, even though it
> clearly isn't from the backtrace.  Presumably, something
> slept from an
> interrupt handler; try turning on sleep-in-spinlock debugging.

I turned on sleep-in-spinlock and it did not reveal anything. I'm trying
some other debug options.

> The root cause was probably something other than the phy code.
I'm not so sure, because it only happens when I run mii-tool agains the
interface useing the bit-banged driver, and then only the first time.



