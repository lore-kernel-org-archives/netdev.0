From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 3/13 net-2.6.26] [DCCP]: dccp_v(4|6)_ctl_socket is
	leaked.
Date: Mon, 31 Mar 2008 10:46:08 -0300
Message-ID: <20080331134608.GF14945@ghostprotocols.net>
References: <1206969367.10660.16.camel@iris.sw.ru> <1206969413-12096-3-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54807 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751104AbYCaNqn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 09:46:43 -0400
Content-Disposition: inline
In-Reply-To: <1206969413-12096-3-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Mar 31, 2008 at 05:16:43PM +0400, Denis V. Lunev escreveu:
> This seems a purism as module can't be unloaded, but though if cleanup method
> is present it should be correct and clean all staff created.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

But please consider adding a inet_ctl_sock_destroy(), even if it only
does this sock_release, as it is the inet_ctl_sock_create() counterpart.

- Arnaldo
