From: bert hubert <ahu@ds9a.nl>
Subject: Re: filtering packtes before OS takes care about them
Date: Mon, 28 Feb 2005 18:38:00 +0100
Message-ID: <20050228173800.GA16865@outpost.ds9a.nl>
References: <09766A6E64A068419B362367800D50C0B58A17@moritz.faps.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Weber Matthias <weber@faps.uni-erlangen.de>
Content-Disposition: inline
In-Reply-To: <09766A6E64A068419B362367800D50C0B58A17@moritz.faps.uni-erlangen.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Feb 28, 2005 at 05:16:57PM +0100, Weber Matthias wrote:

> i need a possibility to catch IP4 packets (from ethernet devices) before
> OS' netmodules (IP, UDP, TCP, ICMP, ARP, ROUTE, NETFILTER ...) takes care
> about them and

Why? It helps if you tell us what you really want, or is this a research
project? 

The earliest place I know of is with tc filter, but that is a netfilter
hook. So part of netfilter will "see" your code.

What you appear to be asking for is a packet filtering network adaptor?
These exist.

> * to modify packet headers and move packets to interface related output
> * buffers

Sure you want an operating system? 

Good luck!

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
