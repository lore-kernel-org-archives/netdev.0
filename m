From: Viswanath Bandaru <vbandaru@broadcom.com>
Subject: RE: [PATCH net-next RFC 0/5] Add NTF_EXT_AGED to control FDB ageing
 in SW or HW
Date: Sat, 21 Feb 2015 11:29:38 +0000
Message-ID: <FFEDCF9956066D4D97C463CC178C7F69F23378@SJEXCHMB06.corp.ad.broadcom.com>
References: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
 <54E76EFA.1050209@cumulusnetworks.com> <54E7876A.3060303@gmail.com>
 <20150221110359.GA2095@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: roopa <roopa@cumulusnetworks.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux@roeck-us.net" <linux@roeck-us.net>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"siva.mannem.lnx@gmail.com" <siva.mannem.lnx@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:58229 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbbBUL3j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 06:29:39 -0500
In-Reply-To: <20150221110359.GA2095@nanopsycho.orion>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> >
> >I agree, in fact, most of the HW I have access to only has a global age
> >timer configuration knob. Is this configurable on a per-port basis for
> >higher end switches, or even maybe per-FDB entry?
> 
> I'm currently not aware of any hw which does not have global age timer.
> But I believe that they will appear. The model that we have now, to
> propagate aging setting of bridge down is more general and should be ok.
> 
> Drivers should probably take care of multi bridge setup with different aging
> setup. Maybe to find minimal time and print a warning?
> 

Setting up the minimal time in such a scenario is good. 

Should we also consider the possibility bridges containing ports from different  devices (and therefore different drivers) ? If that is a possibility, I think the bridge module should take responsibility of finding out the minimal time to pushing to all involved drivers.
