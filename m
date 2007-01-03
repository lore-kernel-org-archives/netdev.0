From: Eric Piel <Eric.Piel@tremplin-utc.net>
Subject: Re: [2.6 patch] the scheduled eepro100 removal
Date: Wed, 03 Jan 2007 01:07:56 +0100
Message-ID: <459AF3DC.1040305@tremplin-utc.net>
References: <20070102215726.GC20714@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, saw@saw.sw.com.sg
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix1-g20.free.fr ([212.27.60.42]:43282 "EHLO
	postfix1-g20.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313AbXACAKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jan 2007 19:10:00 -0500
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20070102215726.GC20714@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

02.01.2007 22:57, Adrian Bunk wrote/a =E9crit:
> This patch contains the scheduled removal of the eepro100 driver.

Hi, I've been using e100 for years with no problem, however more by=20
curiosity than necessity I'd like to know how will be handled the=20
devices which are (supposedly) supported by eepro100 and not by e100?

According to "modinfo eepro100" and "modinfo e100" those devices IDs ar=
e=20
only matched by eepro100:
+alias:          pci:v00008086d00001035sv
+alias:          pci:v00008086d00001036sv
+alias:          pci:v00008086d00001037sv
+alias:          pci:v00008086d00001227sv
+alias:          pci:v00008086d00005200sv
+alias:          pci:v00008086d00005201sv

Are they matched by some joker rule that I haven't noticed in e100, or=20
is support for them really going to disappear?

See you,
Eric
