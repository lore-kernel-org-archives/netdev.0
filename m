From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Fri, 21 Jan 2005 15:24:19 -0600
Message-ID: <200501211524.21364.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain> <200501201114.49517.jeremy.guthrie@berbee.com> <16881.7799.47441.33803@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16881.7799.47441.33803@robur.slu.se>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 21 January 2005 09:23 am, Robert Olsson wrote:
> We have to understand the GC details to 100% confident. Some time to digest
> and a may reboot help.
> I also mentioned routing without the route hash. No spinning in route
> hash and no GC but we trade this for doing a fib lookup for every packet.
> Jamal and I started to play with this at last OLS but it's only tested
> in lab sofar.
I'd like to hold off on that right now.  Things are running pretty good right 
now.  I'm trying to get my hands on a 'test' system to run side-by-side with 
the production system.  We go live Feb 1 with our app so I need to start 
toning down some of the down time.

> For environments with small number of flows it's probably not a good idea
> Length of flows is of course also important. No idea about the result in
> your case.
>
> I have a patch:
>
> ftp:/robur.slu.se:/pub/Linux/net-development/preroute/preroute10.pat
>
> If you feel very brave you can test this. The files to monitor is
> /proc/net/softnet_stat this verify the new packet path.
>
> With rtstat (tot) should show all routed packets. The rate in pps
> we are able to achieve.
I actually think I could have our other test system ready early next week.  
I'll let you know.  

Have a good weekend.

-- 

--------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711
