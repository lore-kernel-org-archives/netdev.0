From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH 0/10] r6040 bugfixing and cleanups
Date: Sun, 13 Jul 2008 13:48:25 +0200
Message-ID: <200807131348.26164.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeff@garzik.org, Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:46366 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752804AbYGMLtG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2008 07:49:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff, Fran=C3=A7ois,

This serie of patches includes bugfixes and cleanups for the r6040 driv=
er.
It was based on Jeff's netdev-2.6 tree, please tell me if you have any =
problems
applying the patches. Thank you.

[PATCH 01/10] r6040: prefix all functions with r6040
[PATCH 02/10] r6040: fix null pointer access and tx timeouts
[PATCH 03/10] r6040: fix scheduling while atomic in r6040_tx_timeout
[PATCH 04/10] r6040: rework the RX buffers allocation routine
[PATCH 05/10] r6040: call napi_disable when puting down the interface a=
nd set lp->dev accordingly
[PATCH 06/10] r6040: completely rework the RX path
[PATCH 07/10] r6040: use definitions for magic values in descriptor sta=
tus
[PATCH 08/10] r6040: change the default waiting time
[PATCH 09/10] r6040: handle RX fifo full and no descriptor interrupts
[PATCH 10/10] r6040: bump release number to 0.18
