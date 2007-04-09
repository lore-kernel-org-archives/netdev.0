From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: two gateways with one NIC
Date: Mon, 9 Apr 2007 12:11:42 -0400
Message-ID: <20070409161142.GC2299@csclub.uwaterloo.ca>
References: <1176003353.686.45.camel@owl.home.ie> <20070408150123.GA3511@csclub.uwaterloo.ca> <1176048615.686.78.camel@owl.home.ie> <20070408182210.GJ3508@csclub.uwaterloo.ca> <1176060547.686.95.camel@owl.home.ie> <20070409145403.GB2299@csclub.uwaterloo.ca> <1176134180.686.102.camel@owl.home.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: W Agtail <wagtail@iol.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:49712 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752169AbXDIQLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 12:11:45 -0400
Content-Disposition: inline
In-Reply-To: <1176134180.686.102.camel@owl.home.ie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 09, 2007 at 04:56:20PM +0100, W Agtail wrote:
> Hi there, and thanks v. much for getting back to me on this one.
> I now have changed iptables on the web servers to the following:
> 
> iptables -t mangle -A POSTROUTING -p tcp --sport 8088 -o eth0 -j MARK
> --set-mark 1
> iptables -t mangle -A POSTROUTING -p tcp --sport 8089 -o eth0 -j MARK
> --set-mark 2
> 
> But I'm still seeing traffic being returned via gw2 for port 8088 :(
> Any ideas? Thanks.

Hmm, I know I have done something like this before (I made all port 80
traffic return through another host rather than the default gateway, but
it was about 3 years ago and I don't remember the exact syntax).

Does your logs show both mark 1 and 2 being used?

Are you sure that the syntax for the ip route rules is right?  I don't
remember if it was fwmark or something else.  I also remember I was
using a mark of 30000ish not, 1 or 2.  No idea if low numbers are
reserved or any such thing.

--
Len Sorensen
