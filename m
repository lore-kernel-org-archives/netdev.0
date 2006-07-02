From: Auke Kok <sofar@foo-projects.org>
Subject: [RESEND] please pull from git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream
Date: Sun, 2 Jul 2006 20:58:40 +0000
Message-ID: <b89f3df8c8420144e0cbf36dd56daa6b@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	auke@foo-projects.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from espresso.foo-projects.org ([193.43.91.203]:6318 "EHLO
	espresso.foo-projects.org") by vger.kernel.org with ESMTP
	id S1750826AbWGBU6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Jul 2006 16:58:43 -0400
To: jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Jeff,

Since my pull request from thursday I haven't heard anything anymore, so I
assume that the changes we made were sufficient.

Needless to say that I would love to see ich8 support make it into 2.6.18rc,
considering that the hardware already is out there and the code has been
tested and validated extensively over the last period.

I hope that can still be accomodated. In that light, please pull:

    git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream


Cheers,

Auke

---
Original message:
---

Jeff,

after comments I've made some adjustments. I'll list them below against the 
old summary. The changes are available from our git-server:

Please pull from:

git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream

These patches are against
     netdev-2.6#upstream 612eff0e3715a6faff5ba1b74873b99e036c59fe
(Brian Haley <brian.haley@hp.com> / [PATCH] s2io: netpoll support)


> Summary of patches:
> 
> [01]: fix loopback ethtool test
> [02]: rework driver hardware reset locking
> [03]: Make PHY powerup/down a function
> [04]: fix CONFIG_PM blocks
> [05]: small performance tweak by removing double code
> [06]: add smart power down code
> [07]: change printk into DPRINTK
> [08]: recycle skb
> [09]: rework module param code with uninitialized values
> [10]: force register write flushes to circumvent broken platforms

Unmodified. See comments here:
http://marc.theaimsgroup.com/?l=linux-netdev&m=115142459725123&w=2 [1]

> [11]: disable CRC stripping workaround

Removed all references to SECRC (crc stripping) instead of leaving it commented.

> [12]: fix adapter led blinking inconsistency
> [13]: add E1000_BIG_ENDIAN symbol

Dropped this patch entirely

> [14]: M88 PHY workaround
> [15]: check return value of _get_speed_and_duplex
> [16]: disable ERT
> [17]: add ich8lan core functions
> [18]: integrate ich8 support into driver
> [19]: allow user to disable ich8 lock loss workaround
> [20]: add ich8lan device ID's
> [21]: increase version to 7.1.9-k2


[1] I can drop #11 in case someone throws a fit ;) - as everyone I'd really 
like to see patches 17->20 queued for 2.6.18 for obvious reasons - this is the 
most important section of these patches!

Cheers,

Auke


---
  drivers/net/e1000/e1000.h         |   10
  drivers/net/e1000/e1000_ethtool.c |  143 +--
  drivers/net/e1000/e1000_hw.c      | 1770 +++++++++++++++++++++++++++++++++++---
  drivers/net/e1000/e1000_hw.h      |  398 ++++++++
  drivers/net/e1000/e1000_main.c    |  384 +++++---
  drivers/net/e1000/e1000_osdep.h   |   13
  drivers/net/e1000/e1000_param.c   |  213 ++--
  7 files changed, 2530 insertions(+), 401 deletions(-)

