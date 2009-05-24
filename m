From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: regression: unregister_netdev() unusably slow
Date: Mon, 25 May 2009 00:23:30 +0300
Message-ID: <200905250023.31056.denys@visp.net.lb>
References: <20090524192150.GE24757@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:59694 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbZEXVb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 May 2009 17:31:58 -0400
In-Reply-To: <20090524192150.GE24757@kvack.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once oprofile gave me hint about similar issue

On Sunday 24 May 2009 22:21:50 Benjamin LaHaise wrote:
> Hi folks,
>
> I just ran a few L2TP tests against 2.6.30-rc7, and it looks like network
> device deletion has become unusably slow.  At least in 2.6.27.10, deleting
> 1000 network interfaces takes less than 2 seconds of real time.  The same
> test run under 2.6.30-rc7 is taking hundreds of seconds to delete 1000
> interfaces at a rate of about 5 per second.  The interfaces all share the
> same local ip address, but each have a single route to a unique client
> ip address.
>
> This is a fairly reasonable use-case, as a single L2TP daemon can be
> terminating thousands of client connections on a single tunnel, and a
> tunnel flap will require tearing down all these interfaces.  I'll work on
> bisecting it, but if someone has any ideas of the source, I'd appreciate
> hearing about it.
>
> 		-ben
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


