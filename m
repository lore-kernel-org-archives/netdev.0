From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Fri, 1 Aug 2003 15:34:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030801153439.4a324c36.davem@redhat.com>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk>
	<20030801154021.GA7696@gtf.org>
	<20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk>
	<20030801162536.GA18574@gtf.org>
	<20030801132037.3f3542ae.davem@redhat.com>
	<3F2AE91D.5090705@pobox.com>
	<3F2AEB33.9050506@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: willy@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F2AEB33.9050506@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 01 Aug 2003 18:35:31 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> We want to provide a sane, ifdef-free path to kcompat, where feasible.

I don't believe it's possible with netdev_ops, without
undoing the entire purpose of what netdev_ops is trying
to accomplish (elimination of code duplication).

Show me, in code not words, how you are able to accomplish
this with SET_NETDEV_OPS() or whatever.  I will not read
english text describing the scheme, I will read only code :)
