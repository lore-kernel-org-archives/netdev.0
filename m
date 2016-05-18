From: Michael Richardson <mcr@sandelman.ca>
Subject: Re: [PATCHv2 bluetooth-next 04/10] ndisc: add addr_len parameter to ndisc_opt_addr_space
Date: Wed, 18 May 2016 17:39:39 -0400
Message-ID: <21520.1463607579@obiwan.sandelman.ca>
References: <1461140382-4784-1-git-send-email-aar@pengutronix.de> <1461140382-4784-5-git-send-email-aar@pengutronix.de> <109698cb-18ae-abdb-34a5-1db5a2e8dc6b@stressinduktion.org> <800c5c08-c2c8-3b44-d457-cdcf6374f280@pengutronix.de> <240084aa-2751-6f24-c07b-662b19a74475@stressinduktion.org> <cdf01ed0-2cc1-667d-40ef-34dcaddce099@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: Alexander Aring <aar@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tuna.sandelman.ca ([209.87.249.19]:60837 "EHLO
	tuna.sandelman.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932197AbcERVjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 17:39:43 -0400
In-Reply-To: <cdf01ed0-2cc1-667d-40ef-34dcaddce099@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=
Content-Type: text/plain


Alexander Aring <aar@pengutronix.de> wrote:
    > What I did in the patch series to store short address in neighbour
    > private data, which makes everything 802.15.4 6lowpan specific.

FYI: there are a whole family of network types which have multiple
addresses (long/short).  This includes:
1) BTLE - RFC 7668 IPv6 over BLUETOOTH(R) Low Energy
2) G.9959 - RFC 7428 Transmission of IPv6 Packets over ITU-T G.9959 Networks
3) BACnet and DECT will be defined.  Some of these have 1 byte short
addresses...
4) the various LPWAN people might be able to do IPv6... we'll see.

I think that we the 802.15.4 specific stuff is fine for now, and we can
figure out it might need generalization later on.
--=-=-=--
