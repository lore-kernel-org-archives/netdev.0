From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Re: [Bonding-devel] [BUG] kernel panic on ifconfig bond0 down
Date: Thu, 18 Sep 2003 12:42:58 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309181242.58258.shmulik.hen@intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A02A464D8@hasmsx403.iil.intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Ned Bass" <bass6@llnl.gov>, <bonding-devel@lists.sourceforge.net>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A02A464D8@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 17 September 2003 11:44 pm, Ned Bass wrote:
> Note that the key to make the panic happen is step #3, bringing up
> the slave interface.  I realize that the slave interface is not
> supposed to be brought up prior to bringing up the bonding
> interface, but should probably not cause a kernel panic either :). 
> The panic occurs immediately after entering 'ifconfig bond0 down'.
> Also, the panic does not occur if I only enslave eth0 but not eth1.
>
>

There was a bug in patch 8 of the cleanup set that left a dangling 
pointer in bond_release_all(). Definitely may bad for not announcing 
that (and removing the patch set from SFG ?). I was relying on the 
fact that people won't test it after I announced the set needs to be 
re-done after finding a potential bug in patch 5.

I'm currently in the final stages of re-creating the set after 
implementing the bug fixes and doing some improvements resulting from 
internal code reviews. Perhaps this time I should publish it as an 
"experimental" patch set and give everyone a chance to try it out 
while our QA group grinds it to dust.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
