From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: Real World Traffic WAS(Re: Route cache performance tests (fwd)
Date: Wed, 11 Jun 2003 20:00:46 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306111953480.2043-100000@netcore.fi>
References: <20030611080924.D39831@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi <hadi@shell.cyberus.ca>
In-Reply-To: <20030611080924.D39831@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 11 Jun 2003, Jamal Hadi wrote:
> Look at the info on nyc-21:
> The 95th percentile of traffic is around 63Kpps.
> Then look at the 95th percentile for number of flows: 72K flows
> 
> this implies that each flow is getting to send less than 1pps.
> 
> I think the number of flows is also interesting. May help in formulizing
> the garbage collection.
> 376K flows(flowi/dst cache) stored at the worst case. In the worst case
> 88K flows are active every second.
> 
> Pekka, do you have similar data you collect as well?

I don't have data on flows but I can say some data from our perspective;

On OC48 backbone interfaces, here:

 - about 600 Mbit/s of traffic equals about 120 kpps
 - a DoS attack of 1.2 Gbit/s was 150 kpps
 - about 1200 Mbit/s of traffic equals about 150 kpps

A significant portion of these is large filetransfers, though (as the 
average packet size is like 600-1000 bytes, calculated from above)...

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
