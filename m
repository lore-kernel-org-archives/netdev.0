From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] netdev_ops
Date: Tue, 08 Jul 2003 15:08:35 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030708.150835.78728697.davem@redhat.com>
References: <20030708163042.GL23597@parcelfarce.linux.theplanet.co.uk>
	<3F0B2D30.4020102@candelatech.com>
	<20030708212551.GL1939@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: willy@debian.org
In-Reply-To: <20030708212551.GL1939@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Matthew Wilcox <willy@debian.org>
   Date: Tue, 8 Jul 2003 22:25:51 +0100

   On Tue, Jul 08, 2003 at 01:44:32PM -0700, Ben Greear wrote:
   > Some of these are missing their netdevice arg?
   > >+	int	(*get_regs_len)(struct ethtool_regs *);
   > >+	int	(*self_test_len)(struct ethtool_test *);
   > >+	int	(*get_strings_len)(struct ethtool_gstrings *);
   > >+	int	(*get_stats_len)(struct ethtool_stats *);
   
   Well, they don't actually need it -- these are more attributes of
   the underlying driver than they are of any individual network device.

Not true, at least for the regs len different variants of the same
chip can have a different sized register set.
