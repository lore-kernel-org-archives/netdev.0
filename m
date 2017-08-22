From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: User per-cpu 64-bit statistics
Date: Tue, 22 Aug 2017 05:56:51 -0700
Message-ID: <1503406611.2499.16.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170804043328.4730-1-f.fainelli@gmail.com>
         <1501824968.25002.35.camel@edumazet-glaptop3.roam.corp.google.com>
         <455c39d3-302e-68ab-3812-112c48ed48c2@gmail.com>
         <1501866711.25002.46.camel@edumazet-glaptop3.roam.corp.google.com>
         <bd260f17-3996-adb5-5c69-353f2a483f84@gmail.com>
         <dd7ee25c-a92c-5104-e788-d6aa5d8b3aeb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <dd7ee25c-a92c-5104-e788-d6aa5d8b3aeb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-08-21 at 17:10 -0700, Florian Fainelli wrote:

> Well if we return 1 from atomic_inc_return() and the previous value was
> zero, of course we are going to be bugging here. The idea behind the
> patch I suppose is to make sure that we always get an odd number upon
> u64_stats_update_begin()/entry, and an even number upon
> u64_stats_update_end()/exit, right?

Yes, this is right.
