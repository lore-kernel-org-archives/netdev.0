From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH V3] net/dt: Add support for overriding phy configuration from device tree
Date: Wed, 05 Feb 2014 09:47:03 +0000
Message-ID: <20140205094703.37C1EC40A89@trevor.secretlab.ca>
References: <7510122.cayuQ6qt8r@wuerfel> < 1389999459-9483-1-git-send-email-matthew.garrett@nebula.com> < CAGVrzcZ4TFd=9KP+aoG47QbmqDJ1i23WBcEWDbzNRUfGmPvZHQ@mail.gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Kishon Vijay Abraham I <kishon@ti.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Matthew Garrett <matthew.garrett@nebula.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcZ4TFd=9KP+aoG47QbmqDJ1i23WBcEWDbzNRUfGmPvZHQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 4 Feb 2014 12:39:41 -0800, Florian Fainelli <f.fainelli@gmail.com> wrote:
> 2014-01-17 Matthew Garrett <matthew.garrett@nebula.com>:
> > Some hardware may be broken in interesting and board-specific ways, such
> > that various bits of functionality don't work. This patch provides a
> > mechanism for overriding mii registers during init based on the contents of
> > the device tree data, allowing board-specific fixups without having to
> > pollute generic code.
> 
> It would be good to explain exactly how your hardware is broken
> exactly. I really do not think that such a fine-grained setting where
> you could disable, e.g: 100BaseT_Full, but allow 100BaseT_Half to
> remain usable makes that much sense. In general, Gigabit might be
> badly broken, but 100 and 10Mbits/sec should work fine. How about the
> MASTER-SLAVE bit, is overriding it really required?
> 
> Is not a PHY fixup registered for a specific OUI the solution you are
> looking for? I am also concerned that this creates PHY troubleshooting
> issues much harder to debug than before as we may have no idea about
> how much information has been put in Device Tree to override that.
> 
> Finally, how about making this more general just like the BCM87xx PHY
> driver, which is supplied value/reg pairs directly? There are 16
> common MII registers, and 16 others for vendor specific registers,
> this is just covering for about 2% of the possible changes.

I would be fine with that too.

g.
