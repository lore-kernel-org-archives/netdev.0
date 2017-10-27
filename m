From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/9] net: dsa: define port types
Date: Fri, 27 Oct 2017 21:37:09 +0200
Message-ID: <20171027193709.GA2385@lunn.ch>
References: <833b871f-e9d4-3d3e-70d5-8aaa19b8f045@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <833b871f-e9d4-3d3e-70d5-8aaa19b8f045@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 27, 2017 at 02:56:51PM +0200, Egil Hjelmeland wrote:
> > The DSA code currently has 3 bitmaps in the dsa_switch structure:
> > cpu_port_mask, dsa_port_mask and enabled_port_mask.
> 
> 
> Hi Vivien
> 
> First I must apologize to everybody for not replying in-thread. Problem
> is that I was not subscribed to netdev. But now I am, so I promise it
> will not happen again :-)
> 
> So to the point. I think DSA need to keep track of multicast
> memberships. As it is now, dsa_switch_mdb_add() include
> the CPU/DSA port(s) in the multicast. But  multicast is never
> removed from the CPU/DSA port(s).

Hi Egil

You should take a look at my patches from a few weeks back. I hope to
make another version next week. These deal with multicast on the CPU
port, or better said, the host wanting to receive a multicast group.

      Andrew
