From: Andi Kleen <andi@firstfloor.org>
Subject: Re: netlink versus pid namespaces
Date: Fri, 15 Oct 2010 17:23:11 +0200
Message-ID: <20101015152311.GC25620@basil.fritz.box>
References: <20101015142357.GA29321@basil.fritz.box>
 <20101015151903.GA3487@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	xemul@openvz.org, virtualization@lists.linux-foundation.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:51032 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756025Ab0JOPXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 11:23:12 -0400
Content-Disposition: inline
In-Reply-To: <20101015151903.GA3487@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 15, 2010 at 07:19:03PM +0400, Alexey Kuznetsov wrote:
> Hello!
> 
> > netlink uses pids (or really tids I hope?) to address sockets
> > associated with processes.
> 
> Not really. It uses port number which is called "pid" occasionally. Bad name.
> Autobind function simply selects tgid of calling process as the first guess.

Thanks for the clarification, Alexey. I guess I should have read more
code :/

-Andi
