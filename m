From: W Agtail <wagtail@iol.ie>
Subject: Re: two gateways with one NIC
Date: Tue, 10 Apr 2007 14:46:42 +0100
Message-ID: <1176212802.686.129.camel@owl.home.ie>
References: <20070408150123.GA3511@csclub.uwaterloo.ca>
	 <1176048615.686.78.camel@owl.home.ie>
	 <20070408182210.GJ3508@csclub.uwaterloo.ca>
	 <1176060547.686.95.camel@owl.home.ie>
	 <20070409145403.GB2299@csclub.uwaterloo.ca>
	 <1176134180.686.102.camel@owl.home.ie>
	 <20070409161142.GC2299@csclub.uwaterloo.ca> <461A663E.4050904@trash.net>
	 <20070409161932.GA2302@csclub.uwaterloo.ca>
	 <1176138144.686.115.camel@owl.home.ie>
	 <20070409172343.GD2299@csclub.uwaterloo.ca>
	 <1176141931.686.120.camel@owl.home.ie>  <461A81E6.7030006@candelatech.com>
Reply-To: wagtail@iol.ie
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpc1-york1-0-0-cust229.leed.cable.ntl.com ([82.3.204.230]:21356
	"EHLO owl.home.ie" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753109AbXDJNrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 09:47:00 -0400
In-Reply-To: <461A81E6.7030006@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-04-09 at 11:11 -0700, Ben Greear wrote:
> W Agtail wrote:
> > Nice one, but unfortunately still doesn't work.
> > I'm now not seeing any marked messages in /var/log/messages and traffic
> > still going via gw2 for port 8088.
> 
> Maybe you could use something like my mac-vlan virtual device to make
> your single NIC look like two NICs?  You can find links to the patch and
> the macvlan-config tool on this page:
> 
> http://www.candelatech.com/~greear/vlan.html
> 
> Ben
> 
> 

Thanks Ben, this looks quite an interesting idea.
Is it possible to create /etc/sysconfig/network-scripts/* in the same
way as ethN:N scripts I wonder?

