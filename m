From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (4/4) add loss option to network delay scheduler
Date: Fri, 18 Jun 2004 14:03:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618140308.6405efed.davem@redhat.com>
References: <20040617155606.558d8eb3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040617155606.558d8eb3@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Jun 2004 15:56:06 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> This enhances the network simulation scheduler to do simple random loss.
> 
> The loss parameter is a simple 32 bit value such that 0 means no loss, and
> 0xffffffff is always drop.  I have a new version of the tc command which takes
> care of conversion from percent to this value.
> 
> Same patch for 2.4 and 2.6

Applied.  But the 2.4.x side I had to apply by hand because in 2.4.x's
copy if pkt_sched.h there is no empty line before the final #endif
and thus patch rejected it.
