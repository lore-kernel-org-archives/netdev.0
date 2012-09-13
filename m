From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: qmi_wwan: call subdriver with control intf
 only
Date: Thu, 13 Sep 2012 16:12:44 -0400 (EDT)
Message-ID: <20120913.161244.1284900183437043445.davem@davemloft.net>
References: <1347308150-19088-1-git-send-email-bjorn@mork.no>
	<1347518675-8427-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48995 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757842Ab2IMUMq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 16:12:46 -0400
In-Reply-To: <1347518675-8427-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Thu, 13 Sep 2012 08:44:35 +0200

> This fixes a hang on suspend due to calling wdm_suspend on
> the unregistered data interface. The hang should have been
> a NULL pointer reference had it not been for a logic error
> in the cdc_wdm code.
>=20
>   commit 230718bd net: qmi_wwan: bind to both control and data interf=
ace
>=20
> changed qmi_wwan to use cdc_wdm as a subdriver for devices with
> a two-interface QMI/wwan function.  The commit failed to update
> qmi_wwan_suspend and qmi_wwan_resume, which were written to handle
> either a single combined interface function, or no subdriver at all.
>=20
> The result was that we called into the subdriver both when the
> control interface was suspended and when the data interface was
> suspended.  Calling the subdriver suspend function with an
> unregistered interface is not supported and will make the
> subdriver bug out.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied, thanks.
