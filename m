From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 2/2] cdc-phonet: autoconfigure Phonet address
Date: Wed, 09 Sep 2009 12:33:09 +0200
Message-ID: <1252492389.8931.31.camel@violet>
References: <1252490406-27951-1-git-send-email-remi@remlab.net>
	 <1252490406-27951-2-git-send-email-remi@remlab.net>
	 <1252491850.8931.28.camel@violet>
	 <1f7692749ea7722ba7f7f4ff9f86acd2@chewa.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:32890 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383AbZIIKdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 06:33:11 -0400
In-Reply-To: <1f7692749ea7722ba7f7f4ff9f86acd2@chewa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Remi,

> > am I understanding this correctly, that even for the USB ones we still
> > have to execute that ioctl() and can not just auto configure them all
> > the time? For the USB ones, I would expect to should plug them in and
> > they are getting configured right away.
> 
> The other patch makes the stack use the ioctl() internally.
> But now I see that I forgot some debug statement :(
> 
> Still, something needs to ifconfig up/ip link set up.

the ifup/ifdown is fine. And if the addresses get set when I plug the
device in, that looks good to me.

Regards

Marcel


