From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next 0/9] net: dsa: define port types
Date: Fri, 27 Oct 2017 14:56:51 +0200
Message-ID: <833b871f-e9d4-3d3e-70d5-8aaa19b8f045@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > The DSA code currently has 3 bitmaps in the dsa_switch structure:
 > cpu_port_mask, dsa_port_mask and enabled_port_mask.


Hi Vivien

First I must apologize to everybody for not replying in-thread. Problem
is that I was not subscribed to netdev. But now I am, so I promise it
will not happen again :-)

So to the point. I think DSA need to keep track of multicast
memberships. As it is now, dsa_switch_mdb_add() include
the CPU/DSA port(s) in the multicast. But  multicast is never
removed from the CPU/DSA port(s).

One option could be that DSA remember mulitcast memberships as bitmaps
of ports. Then it could be handy to have the CPU and DSA ports as
bitmaps too.

It might not fall out that way in the end. But anyway, my suggestion is:
Do patch 1 - 6, which isolates the drivers from the internal structure
of dsa. But hold on to 7 - 9 until there is a plan for better multicast
handling in DSA.

BR
Egil
