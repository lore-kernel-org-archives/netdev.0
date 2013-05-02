From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [GIT] Networking
Date: Thu, 2 May 2013 19:47:25 +0200
Message-ID: <CAHXqBF+Xb0ZVo2tO-0m59JJDrwy5vYX6=jLbts_ZAv5Pk+7SCw@mail.gmail.com>
References: <20130501.164755.1859264969403837546.davem@davemloft.net>
 <CA+55aFzsvyQLLKbuETBqfhpgkSaXH9cvT0O-cQ-mTTXXxcMqwg@mail.gmail.com>
 <1367512467.4000.7.camel@dcbw.foobar.com> <20130502.133947.387694205526879673.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dcbw@redhat.com, torvalds@linux-foundation.org,
	hayeswang@realtek.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130502.133947.387694205526879673.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/5/2 David Miller <davem@davemloft.net>:
> From: Dan Williams <dcbw@redhat.com>
> Date: Thu, 02 May 2013 11:34:27 -0500
>
>> On Wed, 2013-05-01 at 18:28 -0700, Linus Torvalds wrote:
>>> On Wed, May 1, 2013 at 1:47 PM, David Miller <davem@davemloft.net> =
wrote:
>>> >
>>> > Highlights (1721 non-merge commits, this has to be a record of so=
me
>>> > sort):
>>>
>>> Lowlight: it completely breaks my machine with r8169 ethernet.  In =
the
>>> networkmanager applet, it claims no cable connection, which is a bi=
t
>>> odd, because (a) it works with an older kernel and (b) the kernel
>>> messages actually say
>>>
>>>   r8169 0000:01:00.0 eth0: link up
>>
>> NM calls ETHTOOL_GLINK and if that returns success, NM expects the
>> driver to support carrier detection.  NM then listens to netlink for
>> device flags changes, and uses IFF_LOWER_UP to determine carrier on/=
off
>> state.  NM does not use NETIF_F_VLAN_CHALLENGED or any of the other
>> ETHTOOL_GFEATURES flags yet, but will in the future.
>>
>> Is the link status accurately reflected by /sys/class/net/eth0/carri=
er ?
> Something cares about the .../eth0/flags value because with the bit
> ordering different for bits 10 and above things break.

Are you sure it's "flags"? /sys/class/net/*/features were removed some
time ago, and flags don't depend on NETIF_F_*.

Best Regards,
Micha=C5=82 Miros=C5=82aw
