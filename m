From: "Thompson, Ian" <Ian_Thompson@adaptec.com>
Subject: RE: ARP problem?
Date: Wed, 16 Oct 2002 16:17:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E156A23F1885D4119ED800B0D0498A9F02128B96@aimexc07.adaptec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Ben Greear'" <greearb@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> 
> You need arp-filtering:
> 
>      # Set up arp-filter magic.  This, with source-based 
> routing allows us
>      # to have multiple NICs on the same subnet, on the same 
> machine, connected
>      # to the same switch...
>      if [ -f  /proc/sys/net/ipv4/conf/all/arp_filter ];
>      then
> 	echo 1 > /proc/sys/net/ipv4/conf/all/arp_filter
>      else
> 	echo "ERROR: kernel does not support arp_filter.  Don't 
> put more than"
> 	echo "       one interface on the same subnet on the 
> same machine."
> 	echo ""
>      fi
> 

I tried this, and now I'm getting only one ARP response.  However, I get the
same MAC address for ARP broadcasts for either IP address.  Does ARP
filtering turn off all but the first interface when processing ARP packets?
Can I get each interface to answer ARP packets only for its specific IP
address?

Thanks,
-ian
