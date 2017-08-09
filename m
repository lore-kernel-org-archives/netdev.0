From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC net-next] net: Allow name change of IFF_UP interfaces
Date: Wed, 9 Aug 2017 18:10:27 +0200
Message-ID: <20170809161027.GA28694@lunn.ch>
References: <20170809104202.30959-1-vkuznets@redhat.com>
 <CAPA1RqA0q3W-3PsqDpY8_xiBB18SCWTV1gT+BKOTqQfAA5D8Fg@mail.gmail.com>
 <87efskye74.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ???????????? <hideaki.yoshifuji@miraclelinux.com>,
        network dev <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87efskye74.fsf@vitty.brq.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I understand the 'legacy' concern but at the same time we don't want to
> have aftificial limitations too. Name change, in particular, doesn't
> happen 'under the hood' -- someone privileged enough needs to request
> the change.
> 
> Can you think of any particular real world scenarios which are broken by
> the change?

How about:

man 8 dhclient-script

The interface name is passed in $interface to the scripts. Do we get
the old name or the new name? I suspect scripts are going to break if
they are given the old name, which no longer exists.

     Andrew
