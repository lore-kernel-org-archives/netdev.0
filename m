From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v2 01/10] net: dsa: add debugfs interface
Date: Thu, 14 Sep 2017 13:12:31 -0700
Message-ID: <CAKgT0Uf8--Yh9tfkTrh9_dfEYMX5jR6j4unxwxM+WD6E4jk9pA@mail.gmail.com>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
 <20170828191748.19492-2-vivien.didelot@savoirfairelinux.com>
 <20170907193434.GA11006@kroah.com> <87h8wdb8bj.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <CAJGZr0KdOPW5_V3kvWutwTY=BJhfd-=yRDPnvbDBOCuMYWj9OQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Greg KH <gregkh@linuxfoundation.org>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Chris Healy <cphealy@gmail.com>
To: Maxim Uvarov <muvarov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJGZr0KdOPW5_V3kvWutwTY=BJhfd-=yRDPnvbDBOCuMYWj9OQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 14, 2017 at 12:59 PM, Maxim Uvarov <muvarov@gmail.com> wrote:
> debugfs here is very very useful to read registers directly and
> compare what use space tools see. Cool feature to get regs by port and
> use standard tools to diff and print them. Even might be better to
> allow drivers to decode register names and bits values. Once that is
> done driver mainaince will be much easy. I.e. you need only match regs
> with spec from one side and regs with user space tools from other
> side. Of course it's needed only for debuging, not for production. But
> even for production regs dump on something wrong might tell a lot.
>
> Maxim.

Can you clarify what type of registers it is you are wanting to read?
We already have ethtool which is meant to allow reading the device
registers for a given netdev. As long as the port has a netdev
associated it then there is no need to be getting into debugfs since
we should probably just be using ethtool.

Also as Jiri pointed out there is already devlink which would probably
be a better way to get the associated information for those pieces
that don't have a netdev associated with them.

- Alex
