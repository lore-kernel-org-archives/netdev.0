From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v10 1/5] net: add skb_vlan_accel helper
Date: Thu, 2 Jun 2016 15:01:32 -0700
Message-ID: <CAOrHB_Bx9Jr0K-obY8Rtz=Gy7Zot8v+hipj-kiM841PNnsZAaQ@mail.gmail.com>
References: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
	<1464848686-7656-2-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:38532 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932259AbcFBWBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 18:01:37 -0400
Received: from mfilter24-d.gandi.net (mfilter24-d.gandi.net [217.70.178.152])
	by relay4-d.mail.gandi.net (Postfix) with ESMTP id 8B3E917209B
	for <netdev@vger.kernel.org>; Fri,  3 Jun 2016 00:01:35 +0200 (CEST)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
	by mfilter24-d.gandi.net (mfilter24-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id Ou8D3m_tpx_z for <netdev@vger.kernel.org>;
	Fri,  3 Jun 2016 00:01:34 +0200 (CEST)
Received: from mail-it0-f44.google.com (mail-it0-f44.google.com [209.85.214.44])
	(Authenticated sender: pshelar@ovn.org)
	by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 1B7F61720B2
	for <netdev@vger.kernel.org>; Fri,  3 Jun 2016 00:01:34 +0200 (CEST)
Received: by mail-it0-f44.google.com with SMTP id e62so139120908ita.1
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2016 15:01:33 -0700 (PDT)
In-Reply-To: <1464848686-7656-2-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 1, 2016 at 11:24 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> This breaks out some of of skb_vlan_pop into a separate helper.
> This new helper moves the outer-most vlan tag present in packet data
> into metadata.
>
> The motivation is to allow acceleration VLAN tags without adding a new
> one. This is in preparation for a push ethernet header support in Open
> vSwitch.
>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
>

I am not sure we need this function at this point. I will post comment
on patch 4 where it is used.
