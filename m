From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 18/23 v3] mlx4_core: Managing common port filters by
	master function
Date: Wed, 10 Feb 2010 10:47:06 +0200
Message-ID: <15ddcffd1002100047q2904a8b5j2e09748c1a0f0a2e@mail.gmail.com>
References: <49BFC313.1030901@mellanox.co.il> <4B6AEE42.3080900@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il,
	Or Gerlitz <ogerlitz@voltaire.com>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:65324 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892Ab0BJIrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 03:47:10 -0500
Received: by bwz19 with SMTP id 19so1670255bwz.28
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 00:47:07 -0800 (PST)
In-Reply-To: <4B6AEE42.3080900@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yevgeny Petrilin <yevgenyp@mellanox.co.il> wrote:
> The Multicast filter configuration is done by the master,
> that manages the filter which is common for all the functions.
> The VLAN filter is a bitwise OR of all the VLAN filters for all functions,
> the result is a false-positive filter.

Reading through patches "18/23 v3 mlx4_core: Managing common port
filters..." &&
"16/23 v3 mlx4_core: Multi-Function MCG support" I have difficulties
to follow on the
vlan and multicast filtering related changes and proposed architecture.

Can you explain them in a bit more detailed fashion? For example, in
the multicast case I
believe that currently a bloom filter is applied  at the port level
and each packet which
pass the filter and has no registered QP is consumed by the EN driver.
At some point
my understanding was that everyone (all PFs, all VFs, etc) move to
exact match, is it correct?

As for the false-positive vlan filter, I understand that this means
further filtering has to
be applied by some driver. Where you thinking on the 802q driver? what
about the case
where a VF driver is assigned a vlan, does the mlx4 VF code does such filtering?


Or.
