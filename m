From: Dan Hollis <goemon@anime.net>
Subject: Re: [Bonding-devel] Re: [RFC][bonding] Improve VLAN support on top
 of bonding
Date: Tue, 15 Jul 2003 11:16:38 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307151115500.6012-100000@sasami.anime.net>
References: <3F144466.8010003@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Shmulik Hen <shmulik.hen@intel.com>,
   bond-devel <bonding-devel@lists.sourceforge.net>,
   linux-net <linux-net@vger.kernel.org>, linux-netdev <netdev@oss.sgi.com>,
   "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>,
   Jay Vosburgh <fubar@us.ibm.com>, Amir Noam <amir.noam@intel.com>,
   Noam Marom <noam.marom@intel.com>,
   Tsippy Mendelson <tsippy.mendelson@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F144466.8010003@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Jul 2003, Ben Greear wrote:
> Dan Hollis wrote:
> > On Tue, 15 Jul 2003, Ben Greear wrote:
> >>I'd consider ignoring the HW accel unless you can prove it actually helps
> >>performance to a noticeable degree.  I have never seen results of any benchmarking
> >>related to this...
> > For gigabit ethernet, it makes a *H*U*G*E* difference.
> I'm curious to see numbers.  The VLAN shim is only inserting
> a small shim header, at at most shifting the first part of the packet
> when sent a pre-built packet.
> Maybe the hw-accel turns on tcp checksumming or something too??

That is exactly what it does. hw tcp checksumming helps a LOT at gbe rates

-Dan
-- 
[-] Omae no subete no kichi wa ore no mono da. [-]
