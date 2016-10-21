From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v12 7/9] openvswitch: add Ethernet push and pop
 actions
Date: Fri, 21 Oct 2016 14:21:01 +0200
Message-ID: <20161021142101.6e6307df@griffin>
References: <cover.1476708212.git.jbenc@redhat.com>
        <bf8e49c178a2f8ed9adb02e30470be5163d46296.1476708213.git.jbenc@redhat.com>
        <CAOrHB_Bj+0DNePDKQ64Gtx9SyxS4cy20Y-1RLC4Dpd3DKJpsjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35004 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932247AbcJUMVG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Oct 2016 08:21:06 -0400
In-Reply-To: <CAOrHB_Bj+0DNePDKQ64Gtx9SyxS4cy20Y-1RLC4Dpd3DKJpsjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Oct 2016 21:22:21 -0700, Pravin Shelar wrote:
> The eth pop substracts ETH_HLEN but here the length is set. I think it
> should be consistent with respect to eth-pop.

Agreed. Will use skb_reset_mac_len in both, that better reflects what's
going on.

Thanks,

 Jiri
