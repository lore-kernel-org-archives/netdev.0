From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8][BNX2X] resubmit as attachments: add bnx2x to
 Kconfig and Makefile
Date: Wed, 10 Oct 2007 02:34:08 -0700 (PDT)
Message-ID: <20071010.023408.99202743.davem@davemloft.net>
References: <470AFFE3.100@broadcom.com>
	<20071008.212931.82537619.davem@davemloft.net>
	<1191946801.29746.89.camel@eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, mchan@broadcom.com
To: eliezert@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54043
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753294AbXJJJeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 05:34:05 -0400
In-Reply-To: <1191946801.29746.89.camel@eliezer>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eliezer Tamir" <eliezert@broadcom.com>
Date: Tue, 09 Oct 2007 18:20:01 +0200

> Almost all of the zero-filled tables will be removed.
> The rest of the registers do need to be initialized.
> 
> I agree that the number of registers that needs to be initialized is
> huge, but that is caused by the way the hardware was designed.
> 
> The values for the initialization come from several sources:
> Some are derived from HW code (the XML files used to derive the verilog
> code),
> Others (along with much of the machine generated .h files) are generated
> at microcode build time, adding a microcode routine will cause the init
> values to change, using a new variable can cause an .h file to change.
> In the last group which is very small, are registers that are controlled
> by the driver.
> 
> The values in this file really are machine generated, they really are
> not meant to be modified directly by editing the file.
> 
> The registers that are under the driver's control are in the main .c
> and .h files.
...
> The idle check code is not a manufacturing test, it is meant to help
> debug the driver and microcode.
> If the driver sends an invalid command to one of the CPUs which then
> chokes on it, this will tell you which one of them died and the general
> whereabouts of the problem. (ingress CPU X is stuck because output queue
> Y is full)
 ...
> ( Michael has showed me the trick of how to post with evolution, so I
> hope that the mangled patch problem is behind us and I think that I can
> now post everything without a problem, Hallelujah!)

Thanks for the explanations, I look forward to your next
submission.
