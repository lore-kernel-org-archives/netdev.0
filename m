From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next 0/9] mlxsw: Support firmware flash
Date: Mon, 29 May 2017 11:52:27 +0300
Message-ID: <CAJ3xEMgBAWrM2jKRmS0yYi94wEo-8FaV=G24_Z2=emkySV=f4A@mail.gmail.com>
References: <ea7cf005-1f6c-aa87-db90-03d7c77c7d56@mellanox.com>
 <BLUPR0701MB2004EB2F32B4C8C42C5020458DF90@BLUPR0701MB2004.namprd07.prod.outlook.com>
 <fba5a440-ba1e-84bd-d2d2-d011406d3a4a@mellanox.com> <20170523.113859.1803057381093280239.davem@davemloft.net>
 <0daa5c5a-377c-767f-ea19-26c1f22bd30c@mellanox.com> <20170528171735.0e44878d@cakuba.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Yotam Gigi <yotamg@mellanox.com>,
        David Miller <davem@davemloft.net>, Yuval.Mintz@cavium.com,
        Jiri Pirko <jiri@resnulli.us>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Ido Schimmel <idosch@mellanox.com>, mlxsw <mlxsw@mellanox.com>,
        bhutchings@solarflare.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35000 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750854AbdE2Iw2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 04:52:28 -0400
Received: by mail-oi0-f67.google.com with SMTP id v80so10539393oie.2
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 01:52:28 -0700 (PDT)
In-Reply-To: <20170528171735.0e44878d@cakuba.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 29, 2017 at 3:17 AM, Jakub Kicinski <kubakici@wp.pl> wrote:
> On Sun, 28 May 2017 10:26:49 +0300, Yotam Gigi wrote:

>> This problem is even more relevant in the Mellanox HCA driver team, which would
>> like to use that code in order to burn the HCA firmware, but not intend to
>> trigger it on boot time, which means that must have a way for the user to
>> trigger it.

> What would the requirements for the HCA team be?  Is it about loading
> different code or loading HW settings?

For the NIC, as of the (happily growing) large open-systems by nature
install base, we
can't effort for the driver not to load when the currently burned fw
isn't the latest or
the system doesn't have the latest libfirmware clone. We do have to
keep the hassle of
compatibility with older FWs, etc.  As part of the driver/FW API
design we use cap bits
for that matter, and never ask/branch on specific FW or HW versions.

We do want to let user work with the kernel w.o the need to have them
install MLNX or anyone's
tool suit and hence the large value we find in the ethtool flashing of
FW image (the patches
are ready...)

Or.
