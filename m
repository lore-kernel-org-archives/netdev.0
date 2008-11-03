From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: Re: [RESEND] benet: BladeEngine 10Gb NIC driver
Date: Mon, 03 Nov 2008 04:25:12 -0800
Message-ID: <20081103122512.06063fc9@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>, "Greg KH" <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail142.messagelabs.com ([216.82.249.99]:24054 "EHLO
	mail142.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755142AbYKCMZP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 07:25:15 -0500
In-Reply-To: 490DA7E3.8040802@garzik.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we could get more specific feedback about the areas that require cleanup, we can take care of them quickly.  

Since the last posting, we have brought up the driver in a PPC system and fixed some endianness issues.  As soon as I have some specific feedback, we can update the driver with these fixes as well.

Please let me know as soon as the driver is in the staging area.

Thanks.

Subbu 

----- Original Message -----
From: Jeff Garzik [mailto:jeff@garzik.org]
To: Subbu Seetharaman [mailto:subbus@serverengines.com], Greg KH [mailto:greg@kroah.com]
Cc: netdev@vger.kernel.org, LKML [mailto:linux-kernel@vger.kernel.org]
Sent: Sun, 02 Nov 2008 05:15:15 -0800
Subject: Re: [RESEND] benet: BladeEngine 10Gb NIC driver


Subbu Seetharaman wrote:
> Jeff,
> 
> It is more than two months since the benet driver patch was made available as a single file as suggeted by you :
> 
> ftp://ftp.serverengines.com/0001.benet.patch
> 
> I have not seen this applied.  Is there any reason for not applying this  patch ?  Do you want a patch against the latest git tree ?

The overall consensus at this year's Linux Kernel Summit was that this 
driver still needs a lot of cleanup, so I'm gonna try an experiment and 
stick this in the staging tree (currently jgarzik/netdev-2.6.git#benet).

Greg, do I need to do anything beyond simply putting it into the 
directory?  Do I need to add some code to taint, perhaps?

	Jeff


--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

