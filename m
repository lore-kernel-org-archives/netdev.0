From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/1] NET: usb: cdc_ncm: adding MBIM RESET_FUNCTION request and modifying ncm bind common code
Date: Sat, 26 Nov 2016 21:30:03 +0100
Message-ID: <87k2bq7zn8.fsf@miraculix.mork.no>
References: <1479904606-30647-1-git-send-email-dnlplm@gmail.com>
        <1479904606-30647-2-git-send-email-dnlplm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Oliver Neukum <oliver@neukum.org>, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org
To: Daniele Palmas <dnlplm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:41555 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751123AbcKZUaJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 26 Nov 2016 15:30:09 -0500
In-Reply-To: <1479904606-30647-2-git-send-email-dnlplm@gmail.com> (Daniele
        Palmas's message of "Wed, 23 Nov 2016 13:36:46 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Finally, I found my modems (or at least a number of them) again today.
But I'm sorry to say, that the troublesome Huawei E3372h-153 is still
giving us a hard time.  It does not work with your patch. The symptom is
the same as earlier:  The modem returns MBIM frames with 32bit headers.

So for now, I have to NAK this patch.

I am sure we can find a good solution that makes all of these modems
work, but I cannot support a patch that breaks previously working
configurations. Sorry.  I'll do a few experiments and see if there is a
simple fix for this.  Otherwise we'll probably have to do the quirk
game.


Bj=C3=B8rn
