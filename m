From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Subject: Re: [PATCH] Clean the ip_sockglue.c from some ugly ifdefs
Date: Thu, 1 Nov 2007 14:31:13 -0200
Message-ID: <20071101163112.GE13130@ghostprotocols.net>
References: <4729F642.7000709@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60295 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751327AbXKAQbU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 12:31:20 -0400
Content-Disposition: inline
In-Reply-To: <4729F642.7000709@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Thu, Nov 01, 2007 at 06:52:34PM +0300, Pavel Emelyanov escreveu:
> The #idfed CONFIG_IP_MROUTE is sometimes places inside the if-s,
> which looks completely bad. Similar ifdefs inside the functions
> looks a bit better, but they are also not recommended to be used.
> 
> Provide an ifdef-ed ip_mroute_opt() helper to cleanup the code.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Perhaps a better name would be ip_mroute_valid_opt()?

- Arnaldo
