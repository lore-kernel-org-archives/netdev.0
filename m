From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 2/10][NETNS][FRAGS]: Make the
 inet_frag_queue lookup work in namespaces.
Date: Tue, 22 Jan 2008 06:05:58 -0800 (PST)
Message-ID: <20080122.060558.78749619.davem@davemloft.net>
References: <4795F524.8060204@openvz.org>
	<4795F632.6040903@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54089
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751620AbYAVOFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 09:05:51 -0500
In-Reply-To: <4795F632.6040903@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 22 Jan 2008 16:57:06 +0300

> Since fragment management code is consolidated, we
> cannot have the pointer from inet_frag_queue to
> struct net, since we must know what king of fragment
> this is.
> 
> So, I introduce the netns_frags structure. This one
> is currently empty, but will be eventually filled with
> per-namespace attributes. Each inet_frag_queue is
> tagged with this one.
> 
> The conntrack_reasm is not "netns-izated", so it has
> one statis netns_frags instance to keep working in
> init namespace.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
