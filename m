From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (2/4) delay scheduler - retry if requeue fails
Date: Fri, 18 Jun 2004 13:44:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618134446.668b20d4.davem@redhat.com>
References: <20040617155559.5aeba553@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lartc@mailman.ds9a.nl, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040617155559.5aeba553@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Jun 2004 15:55:59 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> If delay scheduler decides not to send the packet right away, it requeues
> it.  If the requeue fails, it should go and look again rather than waking
> up prematurely.
> 
> Same patch should apply to both 2.6 and 2.4

Applied.
