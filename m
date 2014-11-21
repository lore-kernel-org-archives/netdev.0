From: Vadim Kochan <vadim4j@gmail.com>
Subject: RE: [Iproute2,next,v1] ip link: Add ipvlan support to the iproute2/ip util
Date: Fri, 21 Nov 2014 13:44:40 +0200
Message-ID: <CAMw6YJJwKokockGpz_a-nkqOy5TwUgKLgU1SgRNh2JfQTFGF_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:42819 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230AbaKULor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 06:44:47 -0500
Received: by mail-wg0-f42.google.com with SMTP id z12so6294574wgg.1
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 03:44:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mahesh,

> +struct link_util ipvlan_link_util = {
> + .id = "ipvlan",
> + .maxattr = IFLA_IPVLAN_MAX,
> + .parse_opt = ipvlan_parse_opt,
> + .print_opt = ipvlan_print_opt,
> +};

FYI

You can also implement .print_help callback as it was done
for the other link utils, it allows to print usage help for the
specific link util by:

    # ip link help ipvlan

Regards,

Vadim Kochan
