From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] bridge deadlock on device removal
Date: Tue, 7 Sep 2004 14:02:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040907140203.0e41c8e5.davem@davemloft.net>
References: <20040906051523.16e6a431@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040906051523.16e6a431@linux.site>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 6 Sep 2004 05:15:23 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Fixes: https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=131569
> Dead lock in bridge when removing device interface module. br_del_if
> assumes br->lock not held.
> 
> This fixes case of:
> 	brctl addbr b0
> 	brctl addif b0 eth0
> 	rmmod eth0
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Will apply, thanks Stephen.

Is this a 2.6.x only issue?
