From: Patrick McHardy <kaber@trash.net>
Subject: Re: ip route del bug?
Date: Thu, 05 May 2005 20:52:39 +0200
Message-ID: <427A6B77.1030200@trash.net>
References: <427A3370.3090001@skywaywest.com> <20050505113557.7d21baf2@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <hadi@znyx.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050505113557.7d21baf2@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> It looks like an accidental behaviour (of the kernel) in response to
> an ip route delete netlink message with no additional data.

I don't believe it is accidental, it seems correct to me to delete
the default route when no more specific selector is given. To avoid
this, iproute could print an error when dst.bytelen == 0.

Regards
Patrick
