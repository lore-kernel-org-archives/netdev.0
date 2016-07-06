From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] net: bridge: extend MLD/IGMP query stats
Date: Wed, 6 Jul 2016 14:31:18 -0700
Message-ID: <20160706143118.2de2394c@samsung9>
References: <1467832341-5355-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linus.luessing@c0d3.blue,
	roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34974 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932173AbcGFVbZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 17:31:25 -0400
Received: by mail-pf0-f174.google.com with SMTP id c2so83286865pfa.2
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 14:31:24 -0700 (PDT)
In-Reply-To: <1467832341-5355-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  6 Jul 2016 12:12:21 -0700
Nikolay Aleksandrov <razor@blackwall.org> wrote:

> As was suggested this patch adds support for the different versions o=
f MLD
> and IGMP query types. Since the user visible structure is still in ne=
t-next
> we can augment it instead of adding netlink attributes.
> The distinction between the different IGMP/MLD query types is done as
> suggested in Section 7.1, RFC 3376 [1] and Section 8.1, RFC 3810 [2] =
based
> on query payload size and code for IGMP. Since all IGMP packets go th=
rough
> multicast_rcv() and it uses ip_mc_check_igmp/ipv6_mc_check_mld we can=
 be
> sure that at least the ip/ipv6 header can be directly used.
>=20
> [1] https://tools.ietf.org/html/rfc3376#section-7
> [2] https://tools.ietf.org/html/rfc3810#section-8.1
>=20
> Suggested-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Looks good to me.
Acked-by: Stephen Hemminger <stephen@networkplumber.org>
