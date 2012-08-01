From: Ian Molton <ian.molton@codethink.co.uk>
Subject: Re: [PATCH v2 3/6] mv643xx.c: Add basic device tree support.
Date: Wed, 01 Aug 2012 09:50:57 +0100
Message-ID: <5018EDF1.40709@codethink.co.uk>
References: <1343749529-17571-1-git-send-email-ian.molton@codethink.co.uk> <1343749529-17571-4-git-send-email-ian.molton@codethink.co.uk> <20120731164652.GD28852@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org, andrew@lunn.ch,
	thomas.petazzoni@free-electrons.com, ben.dooks@codethink.co.uk,
	arnd@arndb.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:41582 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936Ab2HAIvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 04:51:04 -0400
In-Reply-To: <20120731164652.GD28852@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/07/12 17:46, Andrew Lunn wrote:
> Hi Ian
>
> Probably the driver change will get upstream by netdev. The rest will
> go via the Orion maintainers into arm-soc. So you should probably move
> this board-dt.c change into a patch of its own, or make it part of:
>
> csb1724: Enable device tree based mv643xx ethernet support.
Its not csb1724 specific; I've merged it into

kirkwood: Add a clock setup helper for mv643xx ethernet.

and renamed it to:

kirkwood: Add fixups for DT based mv643xx ethernet.

As this described its purpose better. Hopefully in time, we can
pass something in DT that will allow us to remove that code.

-Ian
