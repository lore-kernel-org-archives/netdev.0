From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] "Lots of unnecessary casts in drivers can be removed"
Date: Thu, 4 Mar 2004 13:14:43 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304131443.62c34eaf.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


[resend]

Dave Jones wrote:
- Lots of unnecessary casts in drivers can be removed.

(from the KJ TODO list).

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

From: Carlo Perassi <carlo@linux.it>

Carlo sent patches to remove unneeded casts from 90 files.
Most of them are in drivers/net/ and will follow...
(not one per file but grouped into families).


and Russell King wrote about the first round of patches:
} I think we should really consider using netdev_priv() in all these places
} so the compiler knows that 'dev' and 'priv' are related.

so this set of patches in round 2 teaches net drivers to use
netdev_priv() in addition to eliminating the unneeded casts.


Here they are again....

Please apply/merge to 2.6.4-rc-current.

Built as much as I have possible, and running with eepro100.

--
~Randy
