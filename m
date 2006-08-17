From: David Miller <davem@davemloft.net>
Subject: Re: bonding: cannot remove certain named devices
Date: Thu, 17 Aug 2006 16:23:40 -0700 (PDT)
Message-ID: <20060817.162340.74748342.davem@davemloft.net>
References: <20060816133811.GA26471@nostromo.devel.redhat.com>
	<Pine.LNX.4.58.0608161636250.2044@be1.lrz>
	<1155799783.7566.5.camel@capoeira>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 7eggert@gmx.de, notting@redhat.com, cate@debian.org,
	7eggert@elstempel.de, shemminger@osdl.org,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:61137
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965154AbWHQXXd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 19:23:33 -0400
To: xavier.bestel@free.fr
In-Reply-To: <1155799783.7566.5.camel@capoeira>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xavier Bestel <xavier.bestel@free.fr>
Date: Thu, 17 Aug 2006 09:29:43 +0200

> Why not simply retricting chars to isalnum() ones ?

As Bill said that would block things like "-" and "_" which are fine.

Bill also mentioned something about "breaking configs going back to
2.4.x" which is bogus because nothing broke when we started blocking
"/" and "." and ".." in networking device names during the addition of
sysfs support for net devices.

Nobody in their right mind puts a space in their network device name.

All you "name purists", go rename the block device name that is used
for your root partition to something with a space in it, and watch how
many startup scripts and command line invocations just explode.

There is absolutely no valid argument for allowing spaces in network
device names.
