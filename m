From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next V2 0/3] Add max rate TXQ attribute
Date: Sun, 15 Mar 2015 23:10:25 +0200
Message-ID: <CAJ3xEMhg_CsCGA5_GkqTb0e=d=sSMJdbQG0gM8CoWvGP8PPGVw@mail.gmail.com>
References: <1426424596-3911-1-git-send-email-ogerlitz@mellanox.com>
	<CALx6S37qzKSJ8cWiCDmfHM=bRy67jup4YriMkL6tw9BUXCRi5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>, Ido Shamay <idos@mellanox.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:34692 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339AbbCOVK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 17:10:26 -0400
Received: by oier21 with SMTP id r21so23208439oie.1
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 14:10:25 -0700 (PDT)
In-Reply-To: <CALx6S37qzKSJ8cWiCDmfHM=bRy67jup4YriMkL6tw9BUXCRi5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 15, 2015 at 7:08 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Sun, Mar 15, 2015 at 6:03 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>> Add the ability to set a max-rate limitation for TX queues.
>> The attribute name is maxrate and the units are Mbs, to make
>> it similar to the existing max-rate limitation knobs (ETS and
>> SRIOV ndo calls).

> Guaranteed rate is often defined in conjunction with maximum rate. It
> might be nice to add a parameter for that to the ndo function in
> anticipation of someone supporting that also.

I see -- so do we really want both from day one...? if this is the
case, I can add that to the ndo with the value of 0 means no limit for
maxrate and no guarantee for minrate

Or.
