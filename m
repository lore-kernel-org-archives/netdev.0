From: David Coulson <david@davidcoulson.net>
Subject: Re: 2.6.10 dst cache overflow
Date: Wed, 16 Feb 2005 08:44:02 -0500
Message-ID: <42134E22.4030808@davidcoulson.net>
References: <1108550412.3799.81.camel@ts2.office.netland.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "J. Simonetti" <jeroens@office.netland.nl>
In-Reply-To: <1108550412.3799.81.camel@ts2.office.netland.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

J. Simonetti wrote:
> I have a linux (Fedora core 3) based router. I does approximately 50Mbps
> aggregated traffic. However once every week (approx) the router dies
> with 'kernel: dst cache overflow' messages flooding syslog. I have
> tracked it down to being an issue with the routing cache.

Funny this came up now - One of my core routers failed last night with 
the identical problem. The route cache was set to 131k routes, although 
I couldn't get a sh prompt on the box even once the switch ports were 
down... Had to sysrq-b it.

I'm running 2.6.11-rc1-bk8 right now on those boxes. 20ish day uptime 
until yesterday and handling around 12Mbit of traffic. 'route -Cn | wc 
-l' right now shows around 29k routes cached. I cranked the route cache 
up to 1m entries, but I figure that's probably excessive.


David

-- 
David J. Coulson
email: david@davidcoulson.net
web: http://www.davidcoulson.net/
phone: (216) 920-3100 / (216) 258-4942
