From: Glen Turner <glen.turner@aarnet.edu.au>
Subject: Re: Linux Routing Performance Update
Date: Sat, 29 Jan 2005 00:26:40 +1030
Message-ID: <41FA4498.6020202@aarnet.edu.au>
References: <16887.39598.648724.421160@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16887.39598.648724.421160@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Finally time for some more testing with a somewhat upgraded equipment.

Thanks very much for the interesting results.

I'm sure other network engineers have experienced software routers where
the pps has dramatically slowed down upon reasonable ACLs and queuing
(Cisco 7500, etc), so some results with netfilter and tc running would
be appreciated, as would tests for any packet re-ordering in output flows.

[ For a reasonable ACL, Team Crymu's list of aggregated Bogon addresses
   is a representative choice.  For a basic QoS, consider three queues:
   control, VoIP, data.  With an approximation to fair queuing + RED on
   the data queue. ]

Best wishes,
Glen
