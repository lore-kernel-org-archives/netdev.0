From: "David S. Miller" <davem@redhat.com>
Subject: Re: patch for common networking error messages
Date: Tue, 17 Jun 2003 09:09:30 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617.090930.102574393.davem@redhat.com>
References: <OFCA1A4F38.D782F1D3-ON85256D48.000A5CED@us.ibm.com>
	<200306170434.h5H4YZPZ003025@turing-police.cc.vt.edu>
	<20030617090859.0ffa0ca8.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, girouard@us.ibm.com, stekloff@us.ibm.com,
   janiceg@us.ibm.com, jgarzik@pobox.com, lkessler@us.ibm.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030617090859.0ffa0ca8.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Tue, 17 Jun 2003 09:08:59 -0700

   Read the hotplug thread to see how Linus
   said, he will never add a binary event daemon interface.

Funny, rtnetlink is exactly this and it is in the tree :-)

Every networking configuration event is transmitted over
rtnetlink sockets to all listeners, in a fixed binary
format.

What Linus doesn't want is this for configuration events,
ie. things like "device appears" not "my ethernet burped"
