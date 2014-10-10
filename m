From: Bruno Thomsen <bth@kamstrup.dk>
Subject: RE: [PATCH] phy/micrel: KSZ8031RNL RMII clock reconfiguration bug
Date: Fri, 10 Oct 2014 11:24:10 +0000
Message-ID: <915054555B5659448ACF8A70E114824D0163C7A7E0@Exchange2010.kamstrup.dk>
References: <1412866094-4972-1-git-send-email-bth@kamstrup.dk>
 <5437AEC0.9010209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Angelo Dureghello <angelo70@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kamstrup.com ([93.167.225.188]:35652 "EHLO
	mail.kamstrup.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbaJJLYQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 07:24:16 -0400
In-Reply-To: <5437AEC0.9010209@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey again

> I add some useful info:
> there is a carrier change after phy is attached, but link state arrives as zero.
>
> [root@xb ~]# cat /sys/class/net/eth0/carrier
> carrier          carrier_changes
> [root@xb ~]# cat /sys/class/net/eth0/carrier
> 0
> [root@xb ~]# cat /sys/class/net/eth0/carrier_changes
> 1

Just to clarify, this patch fixes a real bug and from your first bug rapport it sounded like a similar issue.


On 09/10/2014 16:48, Bruno Thomsen wrote:
> Bug: Unable to send and receive Ethernet packets with Micrel PHY.
>
> Affected devices:
> KSZ8031RNL (commercial temp)
> KSZ8031RNLI (industrial temp)
>
> Description:
> PHY device is correctly detected during probe.
> PHY power-up default is 25MHz crystal clock input and output 50MHz 
> RMII clock to MAC.
> Reconfiguration of PHY to input 50MHz RMII clock from MAC causes PHY 
> to become unresponsive if clock source is changed after Operation Mode 
> Strap Override (OMSO) register setup.
>

Venlig hilsen / Best regards

Kamstrup A/S <http://www.kamstrup.dk> 
Bruno Thomsen
Development engineer
Technology

Kamstrup A/S
Industrivej 28
DK-8660 Skanderborg
Tel:	 +45 89 93 10 00	 
Fax:	 +45 89 93 10 01	 
Dir:	 +45 89 93 13 94	 
E-mail:	 bth@kamstrup.dk	 
Web:	 www.kamstrup.dk	
