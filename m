From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: two gateways with one NIC
Date: Mon, 9 Apr 2007 12:19:32 -0400
Message-ID: <20070409161932.GA2302@csclub.uwaterloo.ca>
References: <1176003353.686.45.camel@owl.home.ie> <20070408150123.GA3511@csclub.uwaterloo.ca> <1176048615.686.78.camel@owl.home.ie> <20070408182210.GJ3508@csclub.uwaterloo.ca> <1176060547.686.95.camel@owl.home.ie> <20070409145403.GB2299@csclub.uwaterloo.ca> <1176134180.686.102.camel@owl.home.ie> <20070409161142.GC2299@csclub.uwaterloo.ca> <461A663E.4050904@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: W Agtail <wagtail@iol.ie>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from csclub1.cs.uwaterloo.ca ([129.97.7.226]:50292 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752325AbXDIQTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 12:19:32 -0400
Content-Disposition: inline
In-Reply-To: <461A663E.4050904@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 09, 2007 at 06:13:50PM +0200, Patrick McHardy wrote:
> As the name suggests, POSTROUTING comes after routing, so marking
> packets there doesn't affect routing. Use PREROUTING for forwarded
> traffic and OUTPUT for locally generated traffic.

I didn't even notice that had been changed.  It used to say PREROUTING
when it was for --dport, and all I suggested changing was --dport to
--sport and change the -o part (probably to nothing at all really since
routing hasn't been decided yet).

Yes it absolutely has to be done PREROUTING.

--
Len Sorensen
