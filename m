From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: sis900: eth0: NULL pointer encountered in Rx ring, skipping
Date: Tue, 18 Jan 2005 11:21:39 +0100
Message-ID: <20050118102139.GA9507@xi.wantstofly.org>
References: <20050118101358.GA9335@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050118101358.GA9335@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jan 18, 2005 at 11:13:58AM +0100, Lennert Buytenhek wrote:

> I can make one of my machines, which has an on-board sis900 NIC, lose
> network connectivity within seconds by doing something like
> "nc -l -p 6666 > /dev/null" and then blasting some data towards it.  When
> this happens, syslog fills up with these messages:
> 
> 	eth0: NULL pointer encountered in Rx ring, skipping

Just before it starts spewing these it says:

	eth0: Memory squeeze,deferring packet.

So apparently it just doesn't deal with OOM very well.


--L
