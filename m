From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH 1/6] Phonet: transport protocol auto-loading
Date: Fri, 3 Oct 2008 16:49:12 +0300
Message-ID: <200810031649.12415.remi.denis-courmont@nokia.com>
References: <200810011312.17288.remi.denis-courmont@nokia.com> <1222855985-22859-1-git-send-email-remi.denis-courmont@nokia.com> <20081001124543.GD970@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "ext Arnaldo Carvalho de Melo" <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:53730 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbYJCNww convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 09:52:52 -0400
In-Reply-To: <20081001124543.GD970@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 01 October 2008 15:45:43 ext Arnaldo Carvalho de Melo, you=
 wrote:
> I wonder if we shouldn't have:
>
> net_pf_request_module(PF_PHONET, protocol)
>
> [acme@doppio linux-2.6]$ grep "net-pf-%d-proto-%d" net/*/*.c
> net/ipv4/af_inet.c: request_module("net-pf-%d-proto-%d-type-%d",
> net/ipv4/af_inet.c: request_module("net-pf-%d-proto-%d",
> net/ipv4/inet_diag.c: request_module("net-pf-%d-proto-%d-type-%d",
> PF_NETLINK, net/ipv6/af_inet6.c:
> request_module("net-pf-%d-proto-%d-type-%d",
> net/ipv6/af_inet6.c: request_module("net-pf-%d-proto-%d",
> net/netlink/af_netlink.c: request_module("net-pf-%d-proto-%d", PF_NET=
LINK,
> protocol);
> [acme@doppio linux-2.6]$=20
>
> Nah, perhaps not...

Looking at it, I could not find a "vrequest_module", which seems to pre=
clude a=20
functional implementation?? Not sure if a macro makes much sense here.

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
