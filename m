From: Daniele Orlandi <daniele@orlandi.com>
Subject: Re: Possible race/deadlock in netdev_unregister
Date: Sat, 29 Jan 2005 01:25:50 +0100
Message-ID: <200501290125.51185.daniele@orlandi.com>
References: <200501282313.30517.daniele@orlandi.com> <20050128153806.2c0fd337@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050128153806.2c0fd337@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Saturday 29 January 2005 00:38, you wrote:
>
> You are probably self-deadlocking on the netlink mutex (rtnl).
> Is your netdevice_notifier handler calling rtnl_lock?

No, I'm just setting an error on all sockets, and sk_state_change()ing them, 
nothing that might sleep, AFAIK.

Even in that case, that wouldn't explain the interaction with hotplug.

I also forgot to say that if the application exists immediately after seeing 
the error on the socket, the problem doesn't show.

Thanks anyway,
Bye!

-- 
  Daniele Orlandi
