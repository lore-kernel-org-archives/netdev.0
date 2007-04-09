From: Ben Greear <greearb@candelatech.com>
Subject: Re: two gateways with one NIC
Date: Mon, 09 Apr 2007 11:11:50 -0700
Message-ID: <461A81E6.7030006@candelatech.com>
References: <20070408150123.GA3511@csclub.uwaterloo.ca>	 <1176048615.686.78.camel@owl.home.ie>	 <20070408182210.GJ3508@csclub.uwaterloo.ca>	 <1176060547.686.95.camel@owl.home.ie>	 <20070409145403.GB2299@csclub.uwaterloo.ca>	 <1176134180.686.102.camel@owl.home.ie>	 <20070409161142.GC2299@csclub.uwaterloo.ca> <461A663E.4050904@trash.net>	 <20070409161932.GA2302@csclub.uwaterloo.ca>	 <1176138144.686.115.camel@owl.home.ie>	 <20070409172343.GD2299@csclub.uwaterloo.ca> <1176141931.686.120.camel@owl.home.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: wagtail@iol.ie
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:54299 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753338AbXDISMF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Apr 2007 14:12:05 -0400
In-Reply-To: <1176141931.686.120.camel@owl.home.ie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

W Agtail wrote:
> Nice one, but unfortunately still doesn't work.
> I'm now not seeing any marked messages in /var/log/messages and traffic
> still going via gw2 for port 8088.

Maybe you could use something like my mac-vlan virtual device to make
your single NIC look like two NICs?  You can find links to the patch and
the macvlan-config tool on this page:

http://www.candelatech.com/~greear/vlan.html

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

