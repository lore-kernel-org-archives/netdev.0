From: Wichert Akkerman <wichert@wiggy.net>
Subject: Re: ipv6 stack seems to forget to send ACKs
Date: Wed, 8 Jan 2003 17:43:47 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030108164347.GK22951@wiggy.net>
References: <20030108150201.GA30490@wiggy.net> <Pine.LNX.4.44.0301081718340.4542-100000@dns.toxicfilms.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Maciej Soltysiak <solt@dns.toxicfilms.tv>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0301081718340.4542-100000@dns.toxicfilms.tv>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Previously Maciej Soltysiak wrote:
> I do not know how many tunnels are in my path, i know that hop distance to
> my tunnel is exactly 1 hop (ipv6 broker and ipv4 provider are the same)

My tunnel provider is 5 hops away. To my knowledge non of the ipv4 or
ipv6 hops in the path are congested and no traffic shaping is done.

> If there is immense traffic at one of the routers (total traffic on an
> interface) stream packets can be simply dropped if there are no queuing
> disciplines that would take eg. flow control into account.

I'll ask the ISPs involved to check if this might be happening, but I
highly doubt it.

> btw. what the hell is JunOs ?

Juniper OS, running on Juniper routers.

Wichert.

-- 
Wichert Akkerman <wichert@wiggy.net>           http://www.wiggy.net/
A random hacker
