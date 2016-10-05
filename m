From: Justin Piszcz <jpiszcz@lucidpixels.com>
Subject: Re: kernel v4.8: iptables logs are truncated with the 4.8 kernel?
Date: Wed, 5 Oct 2016 04:56:10 -0400
Message-ID: <CAO9zADxo0T3=4JHTB4RQi7wG20iZoyP1=L-jrkx=n0RFObNBPg@mail.gmail.com>
References: <CAO9zADwLwLLvxmqiLzxK9A5+--ZnvewMzmUvQ4xdm8HHeFNOsA@mail.gmail.com>
 <CAML_gOcpW=9PEJiE=XoSTRJVjGqAb-DwsWv6JSzkEwp3ivOLfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Liping Zhang <zlpnobody@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAML_gOcpW=9PEJiE=XoSTRJVjGqAb-DwsWv6JSzkEwp3ivOLfA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 4, 2016 at 8:58 PM, Liping Zhang <zlpnobody@gmail.com> wrote:
> Hi Justin,
>
> 2016-10-05 6:02 GMT+08:00 Justin Piszcz <jpiszcz@lucidpixels.com>:
>> Hello,
>>

[ .. ]

>
> Which one are you using? iptables or nftables?
# iptables -V
iptables v1.6.0

>
> Could you please paste the related iptables/nftables rules here?

Rules:

  $IPTABLES -N INPUT_BLOCK
  $IPTABLES -A INPUT_BLOCK -i eth1 -j NFLOG --nflog-group 2
--nflog-prefix "INPUT_BLOCK"
  $IPTABLES -A INPUT_BLOCK -j DROP
  $IPTABLES -A INPUT -j INPUT_BLOCK

Justin.
