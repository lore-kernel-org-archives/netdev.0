From: Patrick McHardy <kaber@trash.net>
Subject: Re: two gateways with one NIC
Date: Mon, 09 Apr 2007 19:14:26 +0200
Message-ID: <461A7472.4030604@trash.net>
References: <1176003353.686.45.camel@owl.home.ie>	 <20070408150123.GA3511@csclub.uwaterloo.ca>	 <1176048615.686.78.camel@owl.home.ie>	 <20070408182210.GJ3508@csclub.uwaterloo.ca>	 <1176060547.686.95.camel@owl.home.ie>	 <20070409145403.GB2299@csclub.uwaterloo.ca>	 <1176134180.686.102.camel@owl.home.ie>	 <20070409161142.GC2299@csclub.uwaterloo.ca> <461A663E.4050904@trash.net>	 <20070409161932.GA2302@csclub.uwaterloo.ca> <1176138144.686.115.camel@owl.home.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	netdev@vger.kernel.org
To: wagtail@iol.ie
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40610 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbXDIROl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 13:14:41 -0400
In-Reply-To: <1176138144.686.115.camel@owl.home.ie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

W Agtail wrote:
> Thanks Patrick for your comments too.
> It seems that you can't mix PREROUTING with --sport or -o.

-o only works after routing.

> I've also changed the ip rule tables to higher numbers, so I now have:
> iptables -t mangle -A PREROUTING -p tcp --dport 8088 -i eth0 -j MARK
> --set-mark 1
> iptables -t mangle -A PREROUTING -p tcp --dport 8089 -i eth0 -j MARK
> --set-mark 2


You should really read some iptables tutorial or at least the manpage.
Its quite easy to set up what you want, but you're again not properly
marking the return traffic.

