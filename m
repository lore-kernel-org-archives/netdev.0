From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 01/10] net: dsa: add debugfs interface
Date: Fri, 15 Sep 2017 17:19:10 +0200
Message-ID: <20170915151910.GG3084@lunn.ch>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
 <20170828191748.19492-2-vivien.didelot@savoirfairelinux.com>
 <20170907193434.GA11006@kroah.com>
 <87h8wdb8bj.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <CAJGZr0KdOPW5_V3kvWutwTY=BJhfd-=yRDPnvbDBOCuMYWj9OQ@mail.gmail.com>
 <CAKgT0Uf8--Yh9tfkTrh9_dfEYMX5jR6j4unxwxM+WD6E4jk9pA@mail.gmail.com>
 <20170914210132.GC3084@lunn.ch>
 <20170915055107.GA1927@nanopsycho.orion>
 <20170915140839.GD3084@lunn.ch>
 <20170915142617.GA2060@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Maxim Uvarov <muvarov@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, kernel@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Chris Healy <cphealy@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:44425 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751152AbdIOPTQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 15 Sep 2017 11:19:16 -0400
Content-Disposition: inline
In-Reply-To: <20170915142617.GA2060@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >   Reg  cpu     lan0    lan1    lan2    lan3    lan4    lan5  global0 global1
> >-----------------------------------------------------------------------------
> >    00: 4e07	4d04	4d04	4d04	4d04	4d04	4d04     0000   00000
> >    01: 403e	003d	003d	003d	003d	003d	003d     0000   00000
> >    02: 0000	0000	0000	0000	0000	0000	0000     0000   00000
> >    03: 3521	3521	3521	3521	3521	3521	3521     0000   00000
> >    04: 0533	373f	373f	373f	373f	373f	373f     0000   00000
> >    05: 8000	0000	0000	0000	0000	0000	0000     0000   00000
> >    06: 005f	003f	003f	003f	003f	003f	003f     0000   00000
> >    07: 002a	002a	002a	002a	002a	002a	002a     0000   00000
> >    08: 2080	2080	2080	2080	2080	2080	2080     0000   00000
> >    09: 0001	0001	0001	0001	0001	0001	0001     0000   00000
> >    0a: 0000	0000	0000	0000	0000	0000	0000     0000   00000
> >    0b: 0020	0000	0000	0000	0000	0000	0000     0000   00000
> >    0c: 0000	0000	0000	0000	0000	0000	0000     0000   00000
> >    0d: 0000	0000	0000	0000	0000	0000	0000     0000   00000
> >    0e: 0000	0000	0000	0000	0000	0000	0000     0000   00000
> >    0f: 9100	dada	dada	dada	dada	dada	dada     0000   00000
> >    10: 0000	0000	0000	0000	0000	0000	0000     0000   00000
> >    11: 0000	0000	0000	0000	0000	0000	0000     0000   00000
> >    12: 0000	0000	0000	0000	0000	0000	0000     0000   00000
> >    13: 0000	00d8	00d8	00d8	00d8	00d8	00d8     0000   00000
> >    14: 0000	0000	0000	0000	0000	0000	0000     0000   00000
> >    15: 0000	0000	0000	0000	0000	0000	0000     0000   00000
> >    16: 0022	0000	0000	0000	0000	0000	0000     0000   00000
> >    17: 0000	0000	0000	0000	0000	0000	0000     0000   00000
> >    18: 3210	2210	2210	2210	2210	2210	2210     0000   00000
> >    19: 7654	7654	7654	7654	7654	7654	7654     0000   00000
> >    1a: 0000	0000	0000	0000	0000	0000	0000     0000   00000
> >    1b: 8000	8000	8000	8000	8000	8000	8000     0000   00000
> >    1c: 0000    0000    0000    0000    0000    0000    0000     0000   00000
> >    1d: 0000    0000    0000    0000    0000    0000    0000     0000   00000
> >    1e: 0000    0000    0000    0000    0000    0000    0000     0000   00000
> >    1f: 0000    0000    0000    0000    0000    0000    0000     0000   00000
> >
> 
> Is this a reg dump per-port?

No. Look at the global0 and global1 columns. These are not port
registers, but switch global registers. The other columns are per
port. We could have a two column table per port for these
registers. However for debugging, it is useful to see the port
registers side-by-side. The difference between ports often gives you
clues as to what is wrong.

The global registers however are scoped to a switch, not a port.

> you can have reg array for each. How the values can change? Is this
> change result of driver<->hw communication? If yes, you might consider
> using devlink hwmsg trace to expose the communication to userspace.

The reason a value changes varies per bit. Some are status, set by the
switch. Some are configuration, set by the driver. They are all mixed
up together. And some registers are actually just multiplexors onto
other tables of registers. You set an opcode in the lower nibble,
address in the middle, set the top bit and busy loop waiting for it to
clear. You can then read a result out of the register, or a near by
register.  So the register dump gives you an idea what the last access
to such a table was.

> I would rather focus on what exactly you need to expose to userspace,
> then we can figure out how to do it. Generic multipurpose arrays should
> be considered as last-resort solution in my opinion.

So go look at Vivien's patches. That is what we want to expose. For a
start. Viviens patches are at the DSA level. Once we get something
accepted at that level, i can imaging drivers want to augment it with
driver specific tables. But we can handle that later.

       Andrew
