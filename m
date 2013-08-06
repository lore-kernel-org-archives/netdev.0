From: Kinley Dorji <kinleyd@gmail.com>
Subject: Re: Bug: alx: Atheros AR8131/AR8151/AR8152/AR8161 Ethernet driver
Date: Tue, 6 Aug 2013 12:05:30 +0600
Message-ID: <CACtZaF+nTHiZ03uebya92b=UVLBXAk9jnM-=Pp3GQ6oSNv8ndA@mail.gmail.com>
References: <CACtZaFJZCWigdT6_vsP9BTRSORzumu33xUtyPtpiDuNn3DQi+w@mail.gmail.com>
	<20130805225752.14e843f7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:64508 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753985Ab3HFGFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 02:05:31 -0400
Received: by mail-we0-f179.google.com with SMTP id t57so3182346wes.38
        for <netdev@vger.kernel.org>; Mon, 05 Aug 2013 23:05:30 -0700 (PDT)
In-Reply-To: <20130805225752.14e843f7@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No sure what conky is using to read them. This is what I get

$ ip -s -d li show dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP mode DEFAULT qlen 1000
    link/ether 90:2b:34:da:42:fd brd ff:ff:ff:ff:ff:ff promiscuity 0
    RX: bytes  packets  errors  dropped overrun mcast
    0          0        0       62      0       0
    TX: bytes  packets  errors  dropped carrier collsns
    0          0        0       0       0       0

$ ethtool -S eth0
no stats available

On Tue, Aug 6, 2013 at 11:57 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Tue, 6 Aug 2013 11:31:39 +0600
> Kinley Dorji <kinleyd@gmail.com> wrote:
>
>> Hi,
>>
>> I'd like to report a bug that has been introduced since the mainlining
>> of the NIC drivers originally in the package AUR/dkms-alx pertaining
>> to the above mentioned network cards.
>>
>> Kernels affected: 3.10.1 - 3.10.5
>> All worked well for kernels <= 3.9.9
>>
>> Environment in which it occurs:
>>
>> kernel: >= 3.10
>> conky: any version (gui/cli)
>> NIC: Any one of the above family
>>
>> conky variables that probe the NIC all return nothing or 0: eg:
>> upspeed, upspeedgraph, downspeed, downspeedgraph
>>
>> A small discussion on the issue:
>> https://bbs.archlinux.org/viewtopic.php?id=166555
>>
>> Network connectivity itself is not a problem - connection works and is stable
>>
>> Conky isn't the problem because it works in kernels <= 3.9.9 with dkms-alx.
>>
>
> What is conky using to read the variables. Perhaps looking at
> CLI tools like:
>   ip -s -d li show dev eth0
> or
>   ethtool -S eth0
>
> would give some indication of which variables are not being incremented.
>
