From: "Mark Ryden" <markryde@gmail.com>
Subject: Compiling as a module using the 2.6.25 git tree
Date: Wed, 16 Jan 2008 15:32:22 +0200
Message-ID: <dac45060801160532k3960d521wbce09bc44be145ee@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.247]:61188 "EHLO
	hs-out-2122.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753153AbYAPNcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 08:32:24 -0500
Received: by hs-out-2122.google.com with SMTP id 54so105484hsz.5
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 05:32:22 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

A question about compiling as module using the 2.6.25 git tree:
I had git cloned the 2.6.25 DaveM tree.
I ran "make menuconfig".
In many cases I see in the help:
"To compile this code as a module, choose M here: the
 module will be called ..."
For example, in "Packet Generator" or in 802.1d Etherent Bridging
(CONFIG_BRIDGE).

However, I cannot choose 'M' here ; the toggle is only between
building into the kernel ('*')
or not.

BRIDGE depends (according to the help) only on CONFIG_NET and I have
CONFIG_NET selected.
more .config | grep  CONFIG_INET
CONFIG_INET=y

Also llc is configured: (though in fact bridge selects llc).
more .config | grep LLC
CONFIG_LLC=y
CONFIG_LLC2=y

And in the Kconfig file we have:
config BRIDGE
        tristate "802.1d Ethernet Bridging"


When I try "make menuconfig" on the kernel of a distro (like FC8) I
**can** choose
bridge as a module. (I see it as 'M').

Any ideas why? Is is something due to using the git tree?

Mark
