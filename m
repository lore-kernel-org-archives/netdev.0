From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 4/7] vxlan: improve vxlan route lookup
 checks.
Date: Wed, 9 Nov 2016 17:41:38 +0100
Message-ID: <20161109174138.410b4385@griffin>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
        <1478371557-71888-5-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43618 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754107AbcKIQlk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 11:41:40 -0500
In-Reply-To: <1478371557-71888-5-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  5 Nov 2016 11:45:54 -0700, Pravin B Shelar wrote:
> Move route sanity check to respective vxlan[4/6]_get_route functions.
> This allows us to perform all sanity checks before caching the dst so
> that we can avoid these checks on subsequent packets.
> This give move accurate metadata information for packet from
> fill_metadata_dst().

The description is misleading, it applies only to one vxlan lwt use case
(openvswitch). For other use cases, the patch has no effect.

I found the current handling of route lookup results irritating, too.
The reason I did not change this while doing vxlan cleanup some time
ago was that I assumed we should not increase dev stats from
vxlan_fill_metadata_dst. Isn't that so?

 Jiri
