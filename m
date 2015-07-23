From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: Retrieve tunnel metadata when
 receiving from vport-netdev
Date: Thu, 23 Jul 2015 14:13:46 -0700
Message-ID: <CALnjE+rGcuF-162_ZeGpiKeTTN6Dm6ByMaWJVZhUNjk6gtzQrg@mail.gmail.com>
References: <f91747edf4825bd5b6641c5c815d0e20f59b7a3a.1437649446.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:38602 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753739AbbGWVNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 17:13:46 -0400
Received: by iggf3 with SMTP id f3so1249957igg.1
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 14:13:46 -0700 (PDT)
In-Reply-To: <f91747edf4825bd5b6641c5c815d0e20f59b7a3a.1437649446.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 23, 2015 at 4:04 AM, Thomas Graf <tgraf@suug.ch> wrote:
> Retrieve the tunnel metadata for packets received by a net_device and
> provide it to ovs_vport_receive() for flow key extraction.
>
> [This hunk was in the GRE patch in the initial series and missed the
>  cut for the initial submission for merging.]
>
> Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Acked-by: Pravin B Shelar <pshelar@nicira.com>
