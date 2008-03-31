From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 1/13 net-2.6.26] [TCP]: Replace socket with sock for
	reset sending.
Date: Mon, 31 Mar 2008 10:44:04 -0300
Message-ID: <20080331134404.GD14945@ghostprotocols.net>
References: <1206969367.10660.16.camel@iris.sw.ru> <1206969413-12096-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54679 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750764AbYCaNoL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 09:44:11 -0400
Content-Disposition: inline
In-Reply-To: <1206969413-12096-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Mar 31, 2008 at 05:16:41PM +0400, Denis V. Lunev escreveu:
> Replace tcp_socket with tcp_sock. This is more effective (less derefferences
> on fast paths). Additionally, the approach is unified to one used in ICMP.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
