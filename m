From: James Ketrenos <jketreno@linux.intel.com>
Subject: Steps for netdev-2.6 inclusion?
Date: Wed, 01 Dec 2004 19:34:59 -0600
Message-ID: <41AE7143.80505@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ok, its been a long time coming, but it appears the ipw* wireless drivers are to 
the point where being more proactive at getting them into the kernel is 
appropriate (at least based on the frequency of emails I'm getting of 'why isn't 
this in mainline?')

So, what would be the set of steps required to get a version in the queue for 
inclusion?

The drivers we have are the ipw2100 (supporting the Intel PRO/Wireless 2100 
Network Connection adapter) and ipw2200 (supporting the Intel PRO/Wireless 
2200BG and 2915ABG Network Connection adapters).  There is also a shared generic 
ieee 802.11 stack (ieee80211*.ko) supporting 802.11b, g, and a for BSS and IBSS 
modes.

The ipw2100 recently was stamped 1.0.0, which means we've put it through a 
validation and stabalization phase.  As we want to try and ensure end users 
don't have to spend all night fighting with their wireless connection just 
because they've updated the kernel, we've adopted the following version 
numbering scheme for the ipw* drivers in the form of of x.y.z, where:

  .z increases from snapshot to snapshot (pushed out as tarballs on SourceForge)
  .y increases (and sets .z to 0) when a snapshot has gone through a regression 
validation cycle.
  .x increases if there are significant functionality changes to the driver.

The idea is to then only have x.y.0 (stable/tested) versions go out for wider 
distribution (kernel inclusion).

For those that are curious, the tip of development for the ipw2100, ipw2200, and 
ieee80211 stack is available at bk://ipw.bkbits.net/ipw-2.6.

Given what I described above, would it be most appropriate to create a 
ipw-2.6-stable bk tree with the parent as netdev-2.6 that we put the stable 
versions of the ipw* drivers into, and then request that be pulled?  The ipw-2.6 
tree could then continue to represent the development tip.  I've searched around 
for some BKMs on this, but haven't found a whole lot.

The ipw2100 1.0.0 snapshot (and newer versions) can be found at 
http://ipw2100.sf.net/#downloads.  The latest ipw2200 snapshot (0.15) is 
available at http://ipw2200.sf.net/#downloads.

Also, we have a Bugzilla database setup for the above drivers at 
http://bughost.org for those that are curious about current remaining issues, etc.

Thanks,
James
