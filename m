From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: qmi_wwan: fix Gobi device probing
Date: Fri, 22 Jun 2012 17:17:35 -0700 (PDT)
Message-ID: <20120622.171735.637204872051168180.davem@davemloft.net>
References: <1340282758-18085-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	H.Siebmanns@t-online.de
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38919 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756380Ab2FWARg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2012 20:17:36 -0400
In-Reply-To: <1340282758-18085-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Thu, 21 Jun 2012 14:45:58 +0200

> Ignoring interfaces with additional descriptors is not a reliable
> method for locating the correct interface on Gobi devices.  There
> is at least one device where this method fails:
> https://bbs.archlinux.org/viewtopic.php?id=3D143506
>=20
> The result is that the AT command port (interface #2) is hidden
> from qcserial, preventing traditional serial modem usage:
 ...
> Use static interface numbers taken from the interface map in
> qcserial for all Gobi devices instead:
 ...
> This should be more reliable over all, and will also prevent the
> noisy "probe failed" messages.  The whitelisting logic is expected
> to be replaced by direct interface number matching in 3.6.
>=20
> Reported-by: Heinrich Siebmanns (Harvey) <H.Siebmanns@t-online.de>
> Cc: <stable@vger.kernel.org> # v3.4: 0000188 USB: qmi_wwan: Make forc=
ed int 4 whitelist generic
> Cc: <stable@vger.kernel.org> # v3.4: f7142e6 USB: qmi_wwan: Add ZTE (=
Vodafone) K3520-Z
> Cc: <stable@vger.kernel.org> # v3.4
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied.
