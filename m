From: Tom Herbert <therbert@google.com>
Subject: Re: low vxlan throughput with tso enabled
Date: Tue, 3 Feb 2015 08:26:27 -0800
Message-ID: <CA+mtBx-7Q1O8KMgmcoKnHurj7DP-4jugkKuqt3b=XaMga2-NEg@mail.gmail.com>
References: <bde634e5-3c57-4e80-9309-670cbd51c1b9@DE-WIE-EXCH3A.green.sophos>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>, svens@stackframe.org,
	Vittorio Curcio <Vittorio.Curcio@sophos.com>
To: Reiner Herrmann <reiner.herrmann@sophos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:51005 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965971AbbBCQ02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 11:26:28 -0500
Received: by mail-ig0-f182.google.com with SMTP id h15so10497319igd.3
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 08:26:28 -0800 (PST)
In-Reply-To: <bde634e5-3c57-4e80-9309-670cbd51c1b9@DE-WIE-EXCH3A.green.sophos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 3, 2015 at 7:50 AM, Reiner Herrmann
<reiner.herrmann@sophos.com> wrote:
> Hi!
>
> I have a vxlan tunnel established between two network interfaces, which
> both have a MTU of 1500. The vxlan interfaces have the same MTU.
> With TSO enabled, I observe low throughput with TCP connections (<100 kB/s).
> Disabling TSO works around this issue and throughput is as expected.
> Can someone please explain how TSO is influencing the tunnel to cause
> such a difference?
>
Please provide more information. What NIC? What is the link rate? What
are you running to test. Also report 'ethtool -k' of both tunnel and
Ethernet interfaces, and tcpdump on the interfaces (to see GSO
packets).

Thanks

> Kind regards,
> Reiner
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
