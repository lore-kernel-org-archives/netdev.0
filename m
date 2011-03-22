From: Jesse Gross <jesse@nicira.com>
Subject: Re: [RFC] net: fix ethtool->set_flags not intended -EINVAL return value
Date: Mon, 21 Mar 2011 19:41:12 -0700
Message-ID: <AANLkTimiDBh=WzT91JbKnucNfJqDzJ8jTHvUobxQ0xk2@mail.gmail.com>
References: <1300446743.11985.317.camel@firesoul.comx.local>
 <4D8385CE.1060205@intel.com> <1300699294.10934.63.camel@firesoul.comx.local>
 <1300700708.2884.10.camel@edumazet-laptop> <99737F4847ED0A48AECC9F4A1974A4B80FD10E8429@MNEXMB2.qlogic.org>
 <20110321123406.GA2376@redhat.com> <20110321134647.GA3126@redhat.com>
 <1300715543.26693.349.camel@localhost> <20110321151015.GA2209@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Amit Salecha <amit.salecha@qlogic.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:47735 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754494Ab1CVCld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 22:41:33 -0400
Received: by qyk7 with SMTP id 7so3052058qyk.19
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2011 19:41:32 -0700 (PDT)
In-Reply-To: <20110321151015.GA2209@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 21, 2011 at 8:10 AM, Stanislaw Gruszka <sgruszka@redhat.com> wrote:
> After commit d5dbda23804156ae6f35025ade5307a49d1db6d7 "ethtool: Add
> support for vlan accleration.", drivers that have NETIF_F_HW_VLAN_TX,
> and/or NETIF_F_HW_VLAN_RX feature, but do not allow enable/disable vlan
> acceleration via ethtool set_flags, always return -EINVAL from that
> function. Fix by returning -EINVAL only if requested features do
> not match current settings and can not be changed by driver.

Looks good to me, thanks for fixing this.
