From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: how to tune a pair of e1000 cards on intel e7501-based system?
Date: Sun, 05 Dec 2004 19:34:18 -0800
Message-ID: <1102304058.3343.217.camel@sfeldma-mobl.dsl-verizon.net>
References: <20041206024437.GB7891@mail.com>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ray Lehtiniemi <rayl@mail.com>
In-Reply-To: <20041206024437.GB7891@mail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-12-05 at 18:44, Ray Lehtiniemi wrote:
> i'm trying to understand how to tune a pair of e1000 cards in
> a server box.  the box is a dual xeon 3.06 with hyperthreading,
> using the intel e7501 chipset, with both cards on hub interface
> D.  the application involves small UDP packets, generally under

These are 82544 cards hanging of P64H2, so they're running at PCI-X, but
at what speed?  Run ethtool -d eth<x> | grep Bus.  The cards support
133Mhz, but having them adjacent on the same P64H2 probably bumps them
down to 100Mhz.  Can you put one on D and the other on another bus?

> 300 bytes. i need to maximize the number of packets per second
> transferred between the two cards.

There is a lot of current traffic on netdev about this topic.  netdev is
the official e1000 mailing this weekend.  :-)

> at the moment, i'm looking at the PCI bus in this box to see
> what might be tweakable.  lspci output for the relevant parts is
> attached below.  
> 
> could anyone give me an idea:
> 
>  - what kind of packets per second i could expect to achieve
>    from this particular system (for small packets)

What kind of numbers are you getting?
What kernel are you using?
What driver tweaks have you made, if any?

-scott
