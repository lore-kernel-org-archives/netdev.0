From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Patch: Idea for RFC2863 conform OperStatus
Date: Mon, 14 Oct 2002 13:50:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15786.44957.210354.599290@robur.slu.se>
References: <3DA82269.CBB65E89@isg.de>
	<20021014103855.GA19962@outpost.ds9a.nl>
	<15786.42910.601886.468716@robur.slu.se>
	<20021014111155.GB20397@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20021014111155.GB20397@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


bert hubert writes:

 > With a bgp full view? 100kpps is not all that impressive in itself isn't it? 
 > We benchmarked our nameserver at 120kpps recently and linux seemed
 > unimpressed :-)


 For me yes. :-) It connects one the major ftp sites... Box can handle 350 
 kpps w/o filter and connection tracking. With current traffic pattern we have 
 160 kpps for wire speed at GIGE.
 

 Yes full BGP. Well even full BGP from 2 peers plus some handful prefixes from 
 other BGP peers.

 ip route | wc -l 
 115670
 
 Gated has 41 MB of BGP routes. With Zebra this would be ~75 MB. 

 ps aux 
 root       232  0.0  7.9 41392 40876  ?  S   Aug 15  36:54 gated 


 Cheers.
						--ro
