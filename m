From: Andrej Krutak <andrej.krutak@sysgo.com>
Subject: check for return value of clk_get() in mpc512x_can_get_clock()
Date: Wed, 23 Feb 2011 14:35:53 +0100
Message-ID: <201102231435.53991.andrej.krutak@sysgo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sysgo.com ([195.145.229.155]:32895 "EHLO mail.sysgo.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754644Ab1BWNmT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 08:42:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

just wanted to inform you - in the mpc512x_can_get_clock() function=20
(drivers/net/can/mscan/mpc5xxx_can.c), there are calls to clg_get(), an=
d later=20
checks

if (!sys_clk) {
and
if (!ref_clk) {

but these should be

if (IS_ERR(sys_clk)) {
and
if (IS_ERR(ref_clk)) {

(otherwise you'll get an oops if something goes wrong with clg_get()).


--=20
Best regards | S pozdravom | Mit freundlichen Gr=FC=DFen

Andrej Krutak
