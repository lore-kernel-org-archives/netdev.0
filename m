From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Re: [Bonding-devel] Re: [bonding] compatibilty issues
Date: Thu, 2 Oct 2003 10:57:46 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310021057.46995.shmulik.hen@intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A02A464F9@hasmsx403.iil.intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <jgarzik@pobox.com>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A02A464F9@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I wrote:
> * Created a version for 2.4 that puts back all old compatibility 
>   stuff that was removed either during the propagation set or the 
>   cleanup set.
> * Created a version for 2.6 that puts back just the compatibility 
>   stuff that was removed in the propagation set (BOND_SETHWADDR, 
>   since we got a complaint from a RH9 user).

Jeff,

I'm going to need a ruling from you:

We understood from David that support of old ioctl definitions (i.e. 
those mapped to SIOCDEVPRIVATE) needs to be removed in the 2.6 
kernel. This will break compatibility with old versions of ifenslave 
(at least 2 years old, but still included in recent distributions 
like Red Hat 9).

If removing those private ioctls is a necessity for 2.6, then breaking 
compatibility with the old ifenslave versions is inevitable, so we 
might as well remove all compatibility stuff from the 2.6 bonding 
module (not just the private ioctls). Of course, we'll keep ifenslave 
fully compatible with all versions of bonding, so the user only needs 
to upgrade the tool once.

Given the above, how do you feel about removing old backward 
compatibility stuff from bonding in 2.6 ?

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
