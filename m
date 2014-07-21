From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: mvebu: Can we make the orion-mdio clock a requirement?
Date: Mon, 21 Jul 2014 16:06:15 -0300
Message-ID: <20140721190614.GB20027@arch.cereza>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jason Cooper <jason@lakedaemon.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:56128 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933419AbaGUTHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 15:07:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Helly everyone,

Currently the mvmdio driver does not require a clock to be declared,
and instead this is optional.

However (almost) all the platforms that currently use it, i.e. the
Armada, Kirkwood and Dove SoCs, require some clock to be enabled before
the MDIO registers can be accessed.

The Orion5x SoC doesn't declare any clock for neither the ethernet node=
,
nor the MDIO node. Is that correct?

Do you think we could make the clock a required property in the mvmdio
devicetree node? How would that behave in the non-DT case?

Thanks,
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
