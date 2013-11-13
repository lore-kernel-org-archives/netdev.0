From: Jacob Avraham <Jacob.Avraham@compass-eos.com>
Subject: network namespaces usage in routing appplications with VRF-like
 features
Date: Wed, 13 Nov 2013 12:56:02 +0000
Message-ID: <292D0115604A314481EE77AB54A844C5672403D2@CMP-EX-DB3.cmpsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from email.compass-eos.com ([84.95.248.193]:43613 "EHLO
	email.compass-eos.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389Ab3KMM4Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 07:56:24 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I'm trying to evaluate the use of network namespaces in some routing ap=
plications, which are currently based on the VFR patchset.
I was thinking about distributing several interfaces among a few namesp=
aces, whereby each namespace has its own routing table(s), ala VRF.
The questions that I have are:
1. Can I open a listening socket that accepts traffic from all interfac=
es in all namespaces? That's the current behavior of my routing protoco=
l daemons.
2. =A0=A0Does RTNETLINK API support adding routes to a particular names=
pace routing table?

Thanks,
Jacob
