From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH RFC v2 00/32] Make DSA switches linux devices.
Date: Sun, 13 Mar 2016 03:26:07 -0400
Message-ID: <87a8m2ltyo.fsf@ketchup.mtl.sfl>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch> <56D88757.7050803@gmail.com> <20160303202716.GQ15541@lunn.ch> <56E357C7.7090309@gmail.com> <20160312170827.GA2186@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34982 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbcCMH0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 03:26:14 -0400
In-Reply-To: <20160312170827.GA2186@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew, Florian,

Andrew Lunn <andrew@lunn.ch> writes:

> It probably means we need to turn slave.c and parts of dsa.c into a
> library. Add a new dsa_v2.c file, containing the new binding
> code. With things like having the switch devices instantiate there own
> MDIO bus, fixed phys on a compatible MDIO bus referenced via phandles,
> etc, I hope we can make parts of the dsa_v2 simpler.

Nothing critical here, but as we are talking about better isolation of
the DSA slave code, wouldn't it be the good moment to make it a
dsa_switch driver, instead of a library? This code is actually pretty
generic, and for example home routers could register an instance of such
module.

Thanks,
-v
