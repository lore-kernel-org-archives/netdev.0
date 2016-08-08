From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net 1/2] net: vxlan: lwt: Use source ip address during
 route lookup.
Date: Mon, 8 Aug 2016 18:03:19 +0200
Message-ID: <20160808180319.77a2f800@griffin>
References: <1470444337-3725-1-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45058 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752125AbcHHQDX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2016 12:03:23 -0400
In-Reply-To: <1470444337-3725-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  5 Aug 2016 17:45:36 -0700, Pravin B Shelar wrote:
> LWT user can specify destination as well as source ip address
> for given tunnel endpoint. But vxlan is ignoring given source
> ip address. Following patch uses both ip address to route the
> tunnel packet. This consistent with other LWT implementations,
> like GENEVE and GRE.
> 
> Fixes: ee122c79d42 ("vxlan: Flow based tunneling").
> Signed-off-by: Pravin B Shelar <pshelar@ovn.org>

Acked-by: Jiri Benc <jbenc@redhat.com>
