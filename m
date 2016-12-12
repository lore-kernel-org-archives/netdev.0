From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/3] net:dsa:mv88e6xxx: use hashtable to store multicast entries
Date: Mon, 12 Dec 2016 10:03:33 -0500
Message-ID: <87r35db35m.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1481549958-1265-1-git-send-email-volodymyr.bendiuga@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
To: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>, andrew@lunn.ch,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:56066 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751677AbcLLPDj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 10:03:39 -0500
In-Reply-To: <1481549958-1265-1-git-send-email-volodymyr.bendiuga@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Volodymyr,

Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com> writes:

> Hashtable will make it extremely faster when inserting fdb entries
> into the forwarding database.

This is hard to follow. As Andrew correctly mentioned, when you have two
or more patches, please format them with --cover-letter, describe them
in patch 0 and send them all together, so that we get a single thread.

You are correct about the ATU get operations being slow. However, we
intentionally keep the driver stateless at the moment to keep it simple.

Unless speed is an issue to fix here, I am quite reluctant to add
caching to this driver yet. What is the issue you are having with the
ATU being slow?

Thanks,

	Vivien
