From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: two gateways with one NIC
Date: Mon, 9 Apr 2007 14:11:58 -0400
Message-ID: <20070409181158.GB2302@csclub.uwaterloo.ca>
References: <20070408182210.GJ3508@csclub.uwaterloo.ca> <1176060547.686.95.camel@owl.home.ie> <20070409145403.GB2299@csclub.uwaterloo.ca> <1176134180.686.102.camel@owl.home.ie> <20070409161142.GC2299@csclub.uwaterloo.ca> <461A663E.4050904@trash.net> <20070409161932.GA2302@csclub.uwaterloo.ca> <1176138144.686.115.camel@owl.home.ie> <20070409172343.GD2299@csclub.uwaterloo.ca> <1176141931.686.120.camel@owl.home.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: W Agtail <wagtail@iol.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from csclub1.cs.uwaterloo.ca ([129.97.7.226]:57134 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753332AbXDISL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 14:11:58 -0400
Content-Disposition: inline
In-Reply-To: <1176141931.686.120.camel@owl.home.ie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 09, 2007 at 07:05:31PM +0100, W Agtail wrote:
> Nice one, but unfortunately still doesn't work.
> I'm now not seeing any marked messages in /var/log/messages and traffic
> still going via gw2 for port 8088.

What does 'iptables -v -t mangle -L' show at the moment?  Have you been
flushing it between attemps to make sure you don't have conflicting
rules?

--
Len Sorensen
