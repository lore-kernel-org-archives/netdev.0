From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ipv6: strange routing behaviors on a multi-interfaces setup
Date: Fri, 27 Sep 2013 10:50:28 +0200
Message-ID: <20130927085028.GE28287@order.stressinduktion.org>
References: <374AB8DA-F970-4652-B147-2094B56BE5F0@sekil.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Emmanuel Thierry <ml@sekil.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54682 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878Ab3I0Iu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 04:50:29 -0400
Content-Disposition: inline
In-Reply-To: <374AB8DA-F970-4652-B147-2094B56BE5F0@sekil.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 25, 2013 at 06:53:07PM +0200, Emmanuel Thierry wrote:
> I experienced these problems on a 3.11.1 kernel but they look to be quite recurrent in the past versions as well. 

A current solution would be to bind the socket to an interface
(SO_BINDTODEVICE) from user-space. I'll look if we can make the next hop
selection more fine grained.

Greetings,

  Hannes
