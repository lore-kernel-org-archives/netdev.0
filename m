From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Re: [Bonding-devel] RE: [PATCH] convering bonding driver /proc interface to seq_file
Date: Sun, 24 Aug 2003 17:50:21 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308241750.21391.shmulik.hen@intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A014C94BF@hasmsx403.iil.intel.com> <3F489659.6040507@free.fr>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Laurent Deniel <laurent.deniel@free.fr>
In-Reply-To: <3F489659.6040507@free.fr>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sunday 24 August 2003 01:41 pm, Laurent Deniel wrote:
> Hen, Shmulik wrote:
> > Guys,
> >
> > Could everyone please hold off the bonding modifications for
> > only a short while until we get this sorted out? We have a
> > bunch of other patch sets in queue that add lots of new stuff
> > and they all depend on that first set being accepted.
>
> Could you give a short description of what is pending ? this
> could avoid duplicate efforts, or worst, incompatible ones ...

Mostly I referred to the 3 patch sets already sent to the lists two 
weeks ago. These patch sets handled back porting stuff from 2.6 to 
2.4, correctly handle propagation of settings from a bond device to 
its slaves and lots of code cleanup. These patches are currently in 
Jeff's net-drivers queue, and hopefully they'll be merged into 2.4 
and from there into 2.6 again, getting 2.6 bonding fully updated.

In the near future, among other things, we are planning to consolidate 
VLAN support over all teaming modes, add support for multiple bonds 
with different modes, add the ability to dynamically add and remove 
bond devices and add the ability to dynamically change bond params. 
Further into the future, we intend to add support for hardware 
offloading stuff like zero copy, checksumming and VLAN, so owners of 
newer adapters can benefit from increased banwidth, etc.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
