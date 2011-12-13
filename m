From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 1/3] option: Removing one bogus and adding some new
 Huawei combinations
Date: Tue, 13 Dec 2011 09:16:00 -0800
Message-ID: <20111213171600.GB17096@kroah.com>
References: <1323750784-32608-1-git-send-email-bjorn@mork.no>
 <1323750784-32608-2-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Bjorn Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3.smtp.messagingengine.com ([66.111.4.27]:34549 "EHLO
	out3.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754053Ab1LMRdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 12:33:03 -0500
Received: from compute4.internal (compute4.nyi.mail.srv.osa [10.202.2.44])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id F0E282143E
	for <netdev@vger.kernel.org>; Tue, 13 Dec 2011 12:33:02 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <1323750784-32608-2-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 13, 2011 at 05:33:02AM +0100, Bjorn Mork wrote:
> From: Bj=F8rn Mork <bjorn@mork.no>
>=20
> Huawei use the product code HUAWEI_PRODUCT_E353 (0x1506) for a
> number of different devices, which each can appear with a number
> of different descriptor sets.  Different types of interfaces
> can be identified by looking at the subclass and protocol fields
>=20
> Subclass 1 protocol 8 is actually the data interface of a CDC
> ECM set, with subclass 1 protocol 9 as the control interface.
> Neither support serial data communcation, and cannot therefore
> be supported by this driver.
>=20
> At the same time, add a few other sets which appear if the
> device is configured in "Windows mode" using this modeswitch
> message:
> 55534243000000000000000000000011060000000100000000000000000000
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
> ---
>  drivers/usb/serial/option.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)

I'll take this one now through the usb tree as it's relevant there.

greg k-h
