From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH 0/10] r6040 bugfixes
Date: Sun, 13 Jul 2008 13:25:07 +0200
Message-ID: <200807131325.08404.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:54753 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbYGMLZm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2008 07:25:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff, Fran=E7ois,

This serie of 10 patches against Jeff's netdev-2.6 tree includes severa=
l=20
critical bugfixes and cleanups for the r6040 driver. Please tell me if =
you=20
have any problems applying those patches to either Fran=E7ois's r6040 b=
ranch
or the netdev repository.

Thank you very much.

[PATCH 01/10] r6040: prefix all functions with r6040
[PATCH 02/10] r6040: fix null pointer access and tx timeouts
[PATCH 03/10] r6040: fix scheduling while atomic in r6040_tx_timeout
[PATCH 04/10] r6040: rework the RX buffers allocation routine
PATCH 05/10] r6040: call napi_disable when puting down the interface an=
d set=20
lp->dev accordingly
[PATCH 06/10] r6040: completely rework the RX path
[PATCH 07/10] r6040: use definitions for magic values in descriptor sta=
tus
[PATCH 08/10] r6040: change the default waiting time
[PATCH 09/10] r6040: handle RX fifo full and no descriptor interrupts
[PATCH 10/10] r6040: bump release number to 0.18
