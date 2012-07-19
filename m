From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: e100: ucode is optional in some cases
Date: Thu, 19 Jul 2012 10:50:49 -0700 (PDT)
Message-ID: <20120719.105049.361659823011039847.davem@davemloft.net>
References: <1342715320-990-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	e1000-devel@lists.sourceforge.net
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752762Ab2GSRuv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:50:51 -0400
In-Reply-To: <1342715320-990-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Thu, 19 Jul 2012 18:28:40 +0200

>   commit 9ac32e1b firmware: convert e100 driver to request_firmware()
>=20
> did a straight conversion of the in-driver ucode to external
> files.  This introduced the possibility of the driver failing
> to enable an interface due to missing ucode. There was no
> evaluation of the importance of the ucode at the time.
>=20
> Based on comments in earlier versions of this driver, and in
> the source code for the FreeBSD fxp driver, we can assume that
> the ucode implements the "CPU Cycle Saver" feature on supported
> adapters.  Although generally wanted, this is an optional
> feature. The ucode source is not available, preventing it from
> being included in free distributions. This creates unnecessary
> problems for the end users. Doing a network install based on a
> free distribution installer requires the user to download and
> insert the ucode into the installer.
>=20
> Making the ucode optional when possible improves the user
> experience and driver usability.
>=20
> The ucode for some adapters include a bugfix, making it
> essential.  We continue to fail for these adapters unless the
> ucode is available.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
> ---
> v2: removed URLs from the patch, converting them to generic
>     descriptions of the sources of information

Applied.
