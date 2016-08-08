From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net 2/2] net: vxlan: lwt: Fix vxlan local traffic.
Date: Mon, 8 Aug 2016 18:03:31 +0200
Message-ID: <20160808180331.0dd7bd69@griffin>
References: <1470444337-3725-1-git-send-email-pshelar@ovn.org>
	<1470444337-3725-2-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40394 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752125AbcHHQDf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2016 12:03:35 -0400
In-Reply-To: <1470444337-3725-2-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  5 Aug 2016 17:45:37 -0700, Pravin B Shelar wrote:
> vxlan driver has bypass for local vxlan traffic, but that
> depends on information about all VNIs on local system in
> vxlan driver. This is not available in case of LWT.
> Therefore following patch disable encap bypass for LWT
> vxlan traffic.
> 
> Fixes: ee122c79d42 ("vxlan: Flow based tunneling").
> Reported-by: Jakub Libosvar <jlibosva@redhat.com>
> Signed-off-by: Pravin B Shelar <pshelar@ovn.org>

Acked-by: Jiri Benc <jbenc@redhat.com>
