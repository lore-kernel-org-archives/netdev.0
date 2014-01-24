From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Force ACK each received tcp segment under no condition
Date: Sat, 25 Jan 2014 00:25:47 +0100
Message-ID: <20140124232547.GS7269@order.stressinduktion.org>
References: <CAK3+h2wd5gEp9oDMZpte-Ed2M3eGSzdkuMJuvk24p=9JcjAzAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vincent Li <vincent.mc.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35719 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903AbaAXXZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jan 2014 18:25:48 -0500
Content-Disposition: inline
In-Reply-To: <CAK3+h2wd5gEp9oDMZpte-Ed2M3eGSzdkuMJuvk24p=9JcjAzAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 24, 2014 at 03:18:19PM -0800, Vincent Li wrote:
> I know this sounds really silly, but I would like to do such test to
> meet my curiosity. is that all I need to do?

Isn't quick ack mode what you're looking for (bcefe17cffd "tcp:
introduce a per-route knob for quick ack"), also settable per setsockopt
TCP_QUICKACK?

Greetings,

  Hannes
