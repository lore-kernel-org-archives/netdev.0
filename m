From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Merge p80211 to ieee80211 subsystem
Date: 28 Mar 2005 14:47:00 -0500
Message-ID: <1112039220.1117.13.camel@jzny.localdomain>
References: <1111740953.17276.84.camel@debian.sh.intel.com>
	 <20050327023706.GH8204@jm.kir.nu>
	 <1111994365.17276.205.camel@debian.sh.intel.com>
	 <20050328145334.GE8180@jm.kir.nu>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Zhu Yi <yi.zhu@intel.com>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20050328145334.GE8180@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-03-28 at 09:53, Jouni Malinen wrote:

> What benefits do you see in having EAPOL/EAP implemented in network
> stack? Did you see it being adding as part of 802.11 stack or network
> stack in general? IEEE 802.1X/EAPOL is used also on wired interfaces..

There is _absolutely_ no need to put this stuff in the kernel. It would
be extremely rude to do so.
Put it in user space  - then you can interface it with Radius, LDAP etc.

cheers,
jamal
