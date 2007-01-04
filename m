From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: Davicom Ethernet (onboard) with many Tx timeouts...
Date: Thu, 4 Jan 2007 20:55:22 -0200
Message-ID: <q7d074-4s6.ln1@tux.abusar.org>
References: <4jut64-6m7.ln1@tux.abusar.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:59377 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964820AbXADW5P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 17:57:15 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1H2bWE-0006cZ-JV
	for netdev@vger.kernel.org; Thu, 04 Jan 2007 23:57:06 +0100
Received: from 200-207-206-233.dsl.telesp.net.br ([200.207.206.233])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 04 Jan 2007 23:57:06 +0100
Received: from fragabr by 200-207-206-233.dsl.telesp.net.br with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 04 Jan 2007 23:57:06 +0100
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 3 Jan 2007 22:33:08 -0200
D=E2niel Fraga <fragabr@gmail.com> wrote:

> Jan  3 22:10:13 belforts vmunix: eth0: Tx timeout - resetting

	Solved by forcing 10Mbps full duplex, using "options dmfe
mode=3D4" in /etc/modprobe.conf.

--=20
http://u-br.net
Linux 2.6.19: Avast! A bilge rat!
Sao Paulo - SP

