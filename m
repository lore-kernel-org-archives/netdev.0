From: pravin shelar <pshelar@ovn.org>
Subject: Re: [ovs-dev] [PATCH v2 net-next] ovs: allow nl 'flow set' to use
 ufid without flow key
Date: Thu, 10 Mar 2016 18:09:13 -0800
Message-ID: <CAOrHB_AC6h04VSeiDWOhYxiRVCMSp82ydZ1-4LmvGGv7K-6ZRA@mail.gmail.com>
References: <CAMEOZhK0kBpdS8uOqYqzQs+6LyWh5K3MWL__CRoThmNRnBN2MQ@mail.gmail.com>
	<1457626499-26585-1-git-send-email-samuel.gauthier@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	ovs dev <dev@openvswitch.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Samuel Gauthier <samuel.gauthier@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:40090 "EHLO
	relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933315AbcCKCJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 21:09:18 -0500
Received: from mfilter34-d.gandi.net (mfilter34-d.gandi.net [217.70.178.165])
	by relay3-d.mail.gandi.net (Postfix) with ESMTP id B880EA80BF
	for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 03:09:16 +0100 (CET)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
	by mfilter34-d.gandi.net (mfilter34-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id Zy-yfboQrOLV for <netdev@vger.kernel.org>;
	Fri, 11 Mar 2016 03:09:15 +0100 (CET)
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	(Authenticated sender: pshelar@ovn.org)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 3BC3EA80C4
	for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 03:09:15 +0100 (CET)
Received: by mail-ig0-f179.google.com with SMTP id av4so366097igc.1
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2016 18:09:15 -0800 (PST)
In-Reply-To: <1457626499-26585-1-git-send-email-samuel.gauthier@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2016 at 8:14 AM, Samuel Gauthier
<samuel.gauthier@6wind.com> wrote:
> When we want to change a flow using netlink, we have to identify it to
> be able to perform a lookup. Both the flow key and unique flow ID
> (ufid) are valid identifiers, but we always have to specify the flow
> key in the netlink message. When both attributes are there, the ufid
> is used. The flow key is used to validate the actions provided by
> the userland.
>
> This commit allows to use the ufid without having to provide the flow
> key, as it is already done in the netlink 'flow get' and 'flow del'
> path. The flow key remains mandatory when an action is provided.
>
> Signed-off-by: Samuel Gauthier <samuel.gauthier@6wind.com>
> ---
> v2:
>  - Restore mask init and parsing
>  - Keep the flow key mandatory when an action is provided
>
Looks good.

Acked-by: Pravin B Shelar <pshelar@ovn.org>
