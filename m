From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: bonding vs 802.3ad/Cisco EtherChannel link agregation
Date: Thu, 12 Sep 2002 18:30:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <288F9BF66CD9D5118DF400508B68C4460475892C@orsmsx113.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "'David S. Miller'" <davem@redhat.com>, borisp@mc.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Bonding does not help with single stream performance.
> You have to have multiple apps generating multiple streams
> of data before you'll realize any improvement.
> Therefore netpipe is a bad test for what you're doing.

The analogy that I like is to imagine a culvert under your driveway and you
want to fill up the ditch on the other side, so you stick your garden hose
in the culvert.  The rate of water flow is good, but you're just not
utilizing the volume (bandwidth) of the culvert.  So you stick your
neighbors garden hose in the culvert.  And so on.  Now the ditch is filling
up.

So stick a bunch of garden hoses (streams) into that culvert (gigabit) and
flood it to the point of saturation, and now measure the efficiency of the
system (CPU %)  How much CPU is left to do other useful work?  The lower the
CPU utilization, the higher the efficiency of the system.

Ok, the analogy is corny, and it doesn't have anything to do with bonding,
but you'd be surprise how often this question comes up.

-scott
