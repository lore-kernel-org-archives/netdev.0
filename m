From: =?UTF-8?B?TmljY29sw7IgQmVsbGk=?= <niccolo.belli@linuxsystems.it>
Subject: Re: [Bug 42809] New: kernel panic when receiving an ipsec packet
Date: Thu, 23 Feb 2012 02:55:13 +0100
Message-ID: <4F459C81.60704@linuxsystems.it>
References: <bug-42809-100@https.bugzilla.kernel.org/>  <20120222092056.5fca788b@nehalam.linuxnetplumber.net>  <4F4528CE.7080702@linuxsystems.it> <4F458F82.3060808@linuxsystems.it> <1329961083.15610.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TmljY29sw7IgQmVsbGk=?= <darkbasic@linuxsystems.it>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>, openadsl-users@lists.sourceforge.net,
	openadsl-devel@lists.sourceforge.net, support@traverse.com.au,
	support@rocksolidelectronics.com, 660804@bugs.debian.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxsystems.it ([2.119.245.41]:52440 "EHLO
	mail.linuxsystems.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754813Ab2BWCEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 21:04:06 -0500
In-Reply-To: <1329961083.15610.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 23/02/2012 02:38, Eric Dumazet ha scritto:
> Which driver handles this Traverse Solos card ?

drivers/atm/solos-pci.c

~# lsmod | grep solos
solos_pci              20009  2
atm                    32378  7 pppoatm,br2684,solos_pci

Niccol=C3=B2
