From: "David S. Miller" <davem@davemloft.net>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 13 Jan 2005 12:00:50 -0800
Message-ID: <20050113120050.0c734df5.davem@davemloft.net>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
	<200501121723.21969.jeremy.guthrie@berbee.com>
	<16870.14259.701771.389978@robur.slu.se>
	<200501131328.34449.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501131328.34449.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 13 Jan 2005 13:28:29 -0600
"Jeremy M. Guthrie" <jeremy.guthrie@berbee.com> wrote:

> You can see below I am over 600K entries before it blows them away and 
> restarts.  How do I bump up the time from 10 minutes to something longer?  
> With the way our system works, entries should be good for a day as we won't 
> reprogram the policy route table but once a day.

Increase /proc/sys/net/ipv4/ip_rt_secret_interval
