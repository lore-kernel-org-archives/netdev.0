From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Poor TCP bandwidth between network namespaces
Date: Mon, 4 Feb 2013 23:52:27 +0100
Message-ID: <20130204225227.GC6898@order.stressinduktion.org>
References: <20130204144320.GG1353@tostaky>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Emmanuel Jeanvoine <emmanuel.jeanvoine@inria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43613 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756060Ab3BDWw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 17:52:28 -0500
Content-Disposition: inline
In-Reply-To: <20130204144320.GG1353@tostaky>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 04, 2013 at 03:43:20PM +0100, Emmanuel Jeanvoine wrote:
> I'm wondering why the overhead is so high when performing TCP 
> transfers between two network namespaces. Do you have any idea about 
> this issue? And possibly, how to increase the bandwidth (without 
> modifying the MTU on the veths) between network namespaces?

You could try Eric's patch (already in net-next) and have a look at the rest
of the discussion:

http://article.gmane.org/gmane.linux.network/253589
