From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.6.5] Bad scheduling while atomic
Date: Fri, 16 Apr 2004 14:56:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040416145632.0b96a3c9.davem@redhat.com>
References: <200404161551.i3GFpD124970@tag.witbe.net>
	<20040416131633.1bfbfa4c@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rol@witbe.net, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040416131633.1bfbfa4c@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 16 Apr 2004 13:16:33 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Bring up/down network devices with lapbether causes scheduling while
> atomic (if preempt enabled).
> 
> The calls to rcu_read_lock are unnecessary since lapb_device_event 
> is called from notifier with the rtnetlink semaphore held, it is
> already protected from the labp_devices list changing.

Applied, thanks Stephen.
