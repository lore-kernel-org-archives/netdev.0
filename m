From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 17:58:54 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610.175854.41658344.davem@redhat.com>
References: <Pine.LNX.4.51.0306101956520.7801@ns.istop.com>
	<20030610.165759.78731321.davem@redhat.com>
	<Pine.LNX.4.51.0306102030530.12166@ns.istop.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, hadi@shell.cyberus.ca, xerox@foonet.net,
   sim@netnation.com, fw@deneb.enyo.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ralph+d@istop.com, ralph@istop.com
In-Reply-To: <Pine.LNX.4.51.0306102030530.12166@ns.istop.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ralph Doncaster <ralph@istop.com>
   Date: Tue, 10 Jun 2003 20:41:13 -0400 (EDT)
   
   This sounded so unbelievable to me that I took a quick look at the code to
   see what I'd have to do to get rid of it.  It appears that gettimeofday is
   not called for every packet; just for ICMP timestamp requests and for IP
   options (ip_options_build and ip_options_compile).

Stop lookin in the IP code.  Look at where we get the packet
from the device, which is one layer up.
