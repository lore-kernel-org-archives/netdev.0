From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RESEND] benet: BladeEngine 10Gb NIC driver
Date: Sun, 02 Nov 2008 08:15:15 -0500
Message-ID: <490DA7E3.8040802@garzik.org>
References: <20080916090021.c4a58c42@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Subbu Seetharaman <subbus@serverengines.com>,
	Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60438 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753470AbYKBNPV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Nov 2008 08:15:21 -0500
In-Reply-To: <20080916090021.c4a58c42@mailhost.serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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


