From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 6/6] netns: configurable number of initial network	namespaces
Date: Tue, 28 Oct 2008 19:21:54 +0100
Message-ID: <49075842.6000901@trash.net>
References: <20081028174659.GF8471@thomson.net> <49075138.80808@trash.net> <49075488.8030002@thomson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Benjamin Thery <benjamin.thery@bull.net>, jleu@mindspring.com,
	linux-vrf-general@lists.sourceforge.net
To: Vivien Chappelier <vivien.chappelier@thomson.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43091 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583AbYJ1SV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 14:21:56 -0400
In-Reply-To: <49075488.8030002@thomson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vivien Chappelier wrote:
>    Yes; the linux-vrf patches had a new netlink message to create/remove 
> the equivalent of a network namespace (ip vrf add 1). I've not ported 
> this feature yet, so this patch is meant to provide another way of 
> setting up networking stacks without the need for a new process for each 
> stack. The ability to dynamically create/remove networking stacks from 
> userspace would definitely be useful.

I see, I didn't realize the process that created a namespace
needs to be kept running. So yes, creating standalone network
namespaces seems to make sense.

>    There are also some very minor advantages in creating the namespaces 
> statically at boot time, such as increasing the chances that the 
> allocation works (though network namespaces are quite small), and 
> improving boot time by avoiding a few calls to /sbin/ip on startup. 
> Since we are running on embedded devices, that is something that matter 
> to us, but it may not be enough to justify the need for this feature. 
> Anyway, I do not think it hurts to have the ability to create static 
> networking stacks at boot time.

I don't have an opinion on this. Thanks for the explanation.
