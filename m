From: Andrea G Forte <andreaf@cs.columbia.edu>
Subject: Re: primary and secondary ip addresses
Date: Fri, 17 Dec 2004 10:58:10 -0500
Message-ID: <41C30212.6000906@cs.columbia.edu>
References: <41912F7A.6000408@redhat.com> <200412161153.51251.hasso@estpak.ee> <Pine.LNX.4.61.0412161103320.30452@filer.marasystems.com> <200412161302.42357.hasso@estpak.ee> <41C2F6E5.5010607@cs.columbia.edu> <Pine.LNX.4.61.0412171621200.15793@filer.marasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hasso Tepper <hasso@estpak.ee>, Harald Welte <laforge@gnumonks.org>,
        Neil Horman <nhorman@redhat.com>, linux-net@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Henrik Nordstrom <hno@marasystems.com>
In-Reply-To: <Pine.LNX.4.61.0412171621200.15793@filer.marasystems.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Which source IP is used by the kernel is determined primary by your 
> routing tables.
>
> The requirements for an IP address to be allowed to be used in the 
> routing table is that the IP address does exists on any of your 
> interfaces, either as primary or secondary.
>
> When you add/delete a primary address to a interface the kernel 
> automatically adds/deletes routes accordingly, including source IP 
> address selection.
>
This does not help, since if I want to use my secondary IP address 
instead of my primary, I cannot delete the primary otherwise all of my 
secondary IPs are lost as well (and since I can only have only one 
primary IP address).

> If the routing table does not have information about which source IP 
> address to use for this traffic then the kernel searches the interface 
> for a valid primary address.
>
I update all the routing entries and eventually things start to work 
again. The problem is that:
-If I use a secondary IP and try to invalidate the primary (i.e. by 
removing its routing table entry), it takes about 500ms for the actual 
change (data packets sent on the secondary IP instead of the primary) to 
take effect.
-If I try to update the primary address directly without creating any 
secondary IP, then it still takes about 300ms for the change to take place.

I honestly do not understand what harm could do to have more than one 
primary address, especially on different subnets.

Cheers,
Andrea

> Regards
> Henrik
