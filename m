From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: iproute2 / tbf with large burst seems broken again
Date: Tue, 25 Aug 2009 15:18:00 +0300
Message-ID: <200908251518.00762.denys@visp.net.lb>
References: <20090825062203.GA5381@ff.dom.local> <200908251416.13888.denys@visp.net.lb> <20090825121344.GA12320@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:38131 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbZHYMUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 08:20:54 -0400
In-Reply-To: <20090825121344.GA12320@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 25 August 2009 15:13:44 Jarek Poplawski wrote:
> I'll need to find more time to rethink your problem (and this patch),
> because it really looks like your tbf usage is very uncommon. Anyway,
> I guess these changes aren't for 2.6.31, unless there're similar
> requests from other users soon.
>
>Thanks for testing,
>Jarek P.
I guess even no need for any kernel :-)

Just maybe good idea in next kernels to document this or handle overflow, that 
it will give warning in kernel. Otherwise user will have non-functional qdisc 
that will not pass traffic.
