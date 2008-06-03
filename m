From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: Re: [PATCH net-next 2/13]bnx2x: Adding bnx2x_link
Date: Tue, 03 Jun 2008 16:46:29 +0300
Message-ID: <1212500790.18098.9.camel@lb-tlvb-eliezer.il.broadcom.com>
References: <1212333127.6967.121.camel@ubuntu804desktop.localdomain>
 <87tzgc283g.fsf@basil.nowhere.org>
 <1212474679.18365.34.camel@ubuntu804desktop.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Andi Kleen" <andi@firstfloor.org>,
	netdev <netdev@vger.kernel.org>, jeff@garzik.org,
	davem@davemloft.net, "Michael Chan" <mchan@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: "Eilon Greenstein" <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2242 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753190AbYFCNqw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 09:46:52 -0400
In-Reply-To: <1212474679.18365.34.camel@ubuntu804desktop.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-06-02 at 23:31 -0700, Eilon Greenstein wrote:
> On Sun, 2008-06-01 at 22:50 +0200, Andi Kleen wrote:
...

> > > +   if (CHIP_REV_IS_FPGA(bp)) {
> >
> > Do the FPGA and IS_EMUL cases really need to be in a production
> driver?
> The support for FPGA and EMUL is part of the code in the main file as
> well. Removing it will require a patch by it self. I will prepare such
> a
> patch, but in lower priority. I agree that it has no place in the
> Kernel

IMHO, it is very much in the interest of the user that we will be able
to run on the emulation the same _exact_ driver version.

In any situation where there is an unexpected firmware event, being able
to reproduce the problem on the emulation takes us most of the way
towards figuring out what is going on.

The firmware can be very tricky to debug on the real chip.

I agree that there is room for a nice little clean-up in this area of
the code, but I would be very reluctant to have it completely removed.

Regards, 
Eliezer


