From: Michael Richardson <mcr@sandelman.ca>
Subject: Re: bluetooth 6lowpan interfaces are not virtual anymore
Date: Wed, 26 Apr 2017 10:55:46 -0400
Message-ID: <383.1493218546@dooku.sandelman.ca>
References: <2d178eb8-3fbc-3385-6e0c-fa9941713959@pengutronix.de> <28530.1492534783@obiwan.sandelman.ca> <11cf222a-0c1f-4136-091d-719ee68824e1@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Network Development <netdev@vger.kernel.org>,
        Jukka Rissanen <jukka.rissanen@linux.intel.com>,
        Luiz Augusto von Dentz <luiz.dentz@gmail.com>,
        "linux-wpan\@vger.kernel.org" <linux-wpan@vger.kernel.org>,
        Linux Bluetooth <linux-bluetooth@vger.kernel.org>
To: Alexander Aring <aar@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.cooperix.net ([176.58.120.209]:35774 "EHLO
        relay.sandelman.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1431229AbdDZPFg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 11:05:36 -0400
In-reply-to: <11cf222a-0c1f-4136-091d-719ee68824e1@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=
Content-Type: text/plain


Alexander Aring <aar@pengutronix.de> wrote:
    >> In a classic SVR4 STREAMS works, it would have been just another
    >> module.  (No, I'm not a fan of *STREAMS* or of SVR4 in general,
    >> although I liked some of the ideas).
    >>

    > ok, I see you complain about "having a virtual on top of wpan
    > interface", or?

    > I wanted to talk at first about the queue handling which is introduced
    > when 6LoWPAN is not a virtual interface anymore. Or do you want to have
    > a queue in front of 6lowpan adaptation (see other mail reply with ASCII
    > graphics).

I would like to have a single queue, as close to the hardware as possible,
such that BQL can do it's thing easily.  Should we rethink outgoing fragment
handling for 6lowpan?  Clearly the BT people had a need.
I don't think they've had a chance to respond to your complaints.

    > We can change that you can run multiple interfaces on one
    > PHY. Currently we just allow one, because address filtering. Disable
    > address filtering
    > we will loose ACK handling on hardware.

Yes, that's a limitation of some hardware, and if you enable multiple PANIDs,
that might be the consequence....

    > I can try to implement all stuff in software "for fun, maybe see what
    > we can do to handle ACK in software, etc" Then you can run multiple

I'm not asking you to do it, I'm asking, now that we've gotten to a certain
point, we have a better idea what the various requirements are, and can we
re-evaluate things and maybe tweak some things.
--=-=-=--
