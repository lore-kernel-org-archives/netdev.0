From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Re: [Bonding-devel] Re: [SET 2][PATCH 2/8][bonding] Propagating  master'ssettings toslaves
Date: Tue, 12 Aug 2003 17:03:15 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308121703.15567.shmulik.hen@intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A0251E69F@hasmsx403.iil.intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <laurent.deniel@thalesatm.com>, <jgarzik@pobox.com>,
   <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <hadi@cyberus.ca>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A0251E69F@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 12 August 2003 04:08 pm, David S. Miller wrote:

> Policy belongs strictly at user space.

Regarding bonding, what policies are we talking about ?
run-time ?  config time ?  both ?  other ?
Our current aim is config time only.

> One of the great things about what Jamal spends his time working
> on is finally a strict seperation of the control layer from
> everything else.  And part of this is moving all of the control
> logic into userspace. Once that is accomplished, I can have my
> toilet flush every time a TCP packet is routed through my system
> and this won't crap up the kernel.

What scope are we talking about here ?
2.4 ?  2.6 ?  2.7 ?  other ?
Our current aim is 2.4 and 2.6.

Taking into account the two statements I made above:
Do you think that what we're doing right now might interfere with what 
Jamal is suggesting ?
Wouldn't it be possible to do things the old way first and than 
convert everything to the new way ?
Shouldn't all this be a part of a totally new project like "bonding2"

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
