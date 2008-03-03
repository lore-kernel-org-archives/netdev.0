From: "Benjamin Thery" <ben.thery@gmail.com>
Subject: Re: [Devel] Re: network namespace ipv6 perfs
Date: Mon, 3 Mar 2008 16:04:47 +0100
Message-ID: <939d53060803030704g5d693c19i34061f1a896d91cd@mail.gmail.com>
References: <47CC0920.6000005@fr.ibm.com> <47CC0E3B.1040809@bull.net>
	 <47CC114F.8050104@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Benjamin Thery" <benjamin.thery@bull.net>,
	"Daniel Lezcano" <dlezcano@fr.ibm.com>,
	"Linux Containers" <containers@lists.osdl.org>,
	"Linux Netdev List" <netdev@vger.kernel.org>,
	"Denis Lunev" <den@openvz.org>
To: "Pavel Emelyanov" <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from po-out-1718.google.com ([72.14.252.152]:9047 "EHLO
	po-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753667AbYCCPEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 10:04:50 -0500
Received: by po-out-1718.google.com with SMTP id b23so8483382poe.1
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2008 07:04:47 -0800 (PST)
In-Reply-To: <47CC114F.8050104@openvz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 3, 2008 at 3:55 PM, Pavel Emelyanov <xemul@openvz.org> wrote:
> Benjamin Thery wrote:
>  > Daniel Lezcano wrote:
>  >> Hi,
>  >>
>  >> Some performance tests was made by Benjamin to watch out the impact of
>  >> the network namespace. The good news is there is no impact when used
>  >> with or without namespaces. That has been checked using a real network
>  >> device inside a network namespace.
>  >>
>  >> These results are consistent with the ones previously made for ipv4.
>  >>
>  >> http://lxc.sourceforge.net/network/bench_ipv6_graph.php
>  >>
>  >> Thanks to Benjamin who did all the performance tests :)
>  >
>  > In these results, may be, there is one thing that should be explained.
>  > It is the CPU utilization overhead in the 'veth' case.
>  >
>  > Compared to physical devices or macvlan, veth interfaces don't benefit
>  > from hardware offloading mechanisms: i.e. checksums have to be computed
>  > by the soft. That explains the big overhead in CPU utilization when
>
>  You can tune the veth devices not to account checksum when unnecessary.

Oh. This is interesting.

You mean with ethtool -K rx/tx?
I will give it a try.

Benjamin

>
>
>  > using this kind of virtual interface.
>  >
>  > Benjamin
>  >
>  >> Regards
>  >>     -- Daniel
>  >>

>--
> To unsubscribe from this list: send the line "unsubscribe netdev" in
>  the body of a message to majordomo@vger.kernel.org
>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
