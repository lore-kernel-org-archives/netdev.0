From: Shmuel Hen <shmulik.hen@intel.com>
Subject: Re: [PATCH 3/6][8021q][2.4] Use VLAN tag set functionality in 8021q module
Date: Wed, 28 Jan 2004 18:57:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401281857.25642.shmulik.hen@intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A03A9CCD5@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="tscii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <bonding-devel@lists.sourceforge.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeff Garzik" <jgarzik@pobox.com>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A03A9CCD5@hasmsx403.iil.intel.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 26 January 2004 19:42, Jeff Garzik wrote:
> Shmuel Hen wrote:
> > Also, speaking of the bonding changes queued in netdev-2.4, some
> > of those have been queued there since 2.4.23 came out. Will those
> > be pushed to Marcelo during 2.4.25 or do you intend to hold them
> > until 2.4.26-preX starts?
>
> Sounds like DaveM and I will need to coordinate a bit, then.

By coordinate, do you mean that you'll take in all of our patches and 
forward them to Dave at the appropriate time, or instead wait for 
Dave to take in the first half (which is not bonding specific) and 
only then take the last half ?

> Note that at some point, IMO you need to plan on 2.6-only
> development, since keeping bonding the same in 2.4 and 2.6 -through
> ABI changes- may not be feasible past the short term.  2.4
> developmnent is intentionally slowing down on Marcelo's side, even
> though vendors are still shipping 2.4.x stuff.

That is our intention. The VLAN enhancements and dynamic configuration 
are the last features we wanted to get into 2.4 before closing (maybe 
zero copy too, since it is trivial). The only thing we do intend to 
keep sending for both 2.4 and 2.6 are bug fixes.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
