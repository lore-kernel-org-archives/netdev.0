From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: A few design questions wrt the hso driver.
Date: Wed, 01 Oct 2008 15:57:09 +0300
Message-ID: <48E373A5.5050001__44695.6376232722$1222865952$gmane$org@teltonika.lt>
References: <48E36A0A.9080003@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Bird
	<public-ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@hugh.gmane.org>,
	Linux USB kernel mailing list
	<public-linux-usb-u79uwXL29TY76Z2rM5mHXA@hugh.gmane.org>,
	Linux netdev Mailing list
	<public-netdev-u79uwXL29TY76Z2rM5mHXA@hugh.gmane.org>,
	"Greg Kroah-Hartman"@hugh.gmane.org
To: Denis Joseph Barrow
	<public-D.Barow-x9gZzRpC1QbQT0dZR+AlfA@hugh.gmane.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blaine.gmane.org ([80.91.229.8]:60157 "EHLO hugh.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753369AbYJAM5e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 08:57:34 -0400
Received: from public by hugh.gmane.org with local (Exim 4.63)
	(envelope-from <public@hugh.gmane.org>)
	id 1Kl1Gf-0002Sr-OO
	for netdev@vger.kernel.org; Wed, 01 Oct 2008 14:57:25 +0200
In-Reply-To: <48E36A0A.9080003@option.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Denis Joseph Barrow wrote:
> Hi,
> I'm currently beginning to test the modem functionality of the hso driver.
> 
> Simple question first.
> There is this comment near the top of hso.c
> Interface 2:	Standard modem interface - circuit switched interface, should
> 		not be used.

AFAIK this interface is disabled in most 'hso' devices firmware.
Although it was enabled in some devices what made them work with 'option'
driver. Thats how some IDs got there :)

> 
> Who put this comment in & why? is it obselete?
> The modem port at least works on minicom till the point
> of setting up the ppp connection.

