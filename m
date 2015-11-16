From: Premkumar Jonnala <pjonnala@broadcom.com>
Subject: RE: [PATCH] bonding: Offloading bonds to hardware
Date: Mon, 16 Nov 2015 06:49:49 +0000
Message-ID: <77EF4405DD4BB54AACCE7DB593DF6A9AA09053@SJEXCHMB14.corp.ad.broadcom.com>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9FD653@SJEXCHMB14.corp.ad.broadcom.com>
	<56462E38.5090600@gmail.com>
 <20151113.141006.1048458234203733687.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"nikolay@cumulusnetworks.com" <nikolay@cumulusnetworks.com>,
	"idosch@mellanox.com" <idosch@mellanox.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:46952 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbbKPGtv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 01:49:51 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Premkumar Jonnala
> Sent: Monday, November 16, 2015 11:42 AM
> To: 'David Miller'; f.fainelli@gmail.com
> Cc: netdev@vger.kernel.org; sfeldma@gmail.com; jiri@resnulli.us;
> nikolay@cumulusnetworks.com; idosch@mellanox.com;
> gospo@cumulusnetworks.com
> Subject: RE: [PATCH] bonding: Offloading bonds to hardware
> 
> 
> 
> > -----Original Message-----
> > From: David Miller [mailto:davem@davemloft.net]
> > Sent: Saturday, November 14, 2015 12:40 AM
> > To: f.fainelli@gmail.com
> > Cc: Premkumar Jonnala; netdev@vger.kernel.org; sfeldma@gmail.com;
> > jiri@resnulli.us; nikolay@cumulusnetworks.com; idosch@mellanox.com;
> > gospo@cumulusnetworks.com
> > Subject: Re: [PATCH] bonding: Offloading bonds to hardware
> >
> > From: Florian Fainelli <f.fainelli@gmail.com>
> > Date: Fri, 13 Nov 2015 10:38:48 -0800
> >
> > > This is a good explanation of why you want the changes, and how this is
> > > implemented in a system utilizing that, but this is not documenting why
> > > you are making these changes to the bonding code, nor how they are
> > > supposed to be used by an implementor driver, since there is no such
> > > user posted (yet?).
> >
> > I am basically not even going to look at proposals for new device ops
> > that don't also show an actual user of the new interfaces.
> >
> > That's not how we do development, and not providing a real example
> > user of a new set of interfaces makes it impossible to properly review
> > such changes.
> 
> Thank you for the feedback David.  I am currently handling/implementing
> these notifications in a custom (closed source) driver.  I will update the diff
> with an actual demo of the handler, and resend the diffs.

Clarification: When I say a "closed source" driver, I was implying a closed-source
user-level application that programs hardware.

Thanks
Prem

> 
> Thanks
> Prem
