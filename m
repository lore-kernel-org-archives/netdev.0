From: Matthew Wilcox <willy@debian.org>
Subject: Re: [PATCH] netdev_ops
Date: Tue, 8 Jul 2003 22:25:51 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030708212551.GL1939@parcelfarce.linux.theplanet.co.uk>
References: <20030708163042.GL23597@parcelfarce.linux.theplanet.co.uk> <3F0B2D30.4020102@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <willy@debian.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <3F0B2D30.4020102@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jul 08, 2003 at 01:44:32PM -0700, Ben Greear wrote:
> Some of these are missing their netdevice arg?
> >+	int	(*get_regs_len)(struct ethtool_regs *);
> >+	int	(*self_test_len)(struct ethtool_test *);
> >+	int	(*get_strings_len)(struct ethtool_gstrings *);
> >+	int	(*get_stats_len)(struct ethtool_stats *);

Well, they don't actually need it -- these are more attributes of
the underlying driver than they are of any individual network device.
I suspect at least one of them isn't needed, and I'm sure the e1000 guys
are about to tell me which one ;-)

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
