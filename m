From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 1/7] vxlan: avoid vlan processing in vxlan
 device.
Date: Wed, 9 Nov 2016 17:04:36 +0100
Message-ID: <20161109170436.0558c4a6@griffin>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
        <1478371557-71888-2-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49696 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933250AbcKIQEk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 11:04:40 -0500
In-Reply-To: <1478371557-71888-2-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  5 Nov 2016 11:45:51 -0700, Pravin B Shelar wrote:
> VxLan device does not have special handling for vlan taging on egress.
> Therefore it does not make sense to expose vlan offloading feature.

Makes sense. Though it would be good to have a more detailed
description, I already started writing a reply that the patch changes
VXLAN behavior when I realized it doesn't.

If you're respinning for another reasons, please make the description
a bit more elaborate. Not worth resending just for this, though, IMHO.

Acked-by: Jiri Benc <jbenc@redhat.com>
