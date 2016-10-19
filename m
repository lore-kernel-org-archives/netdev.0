From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v12 9/9] openvswitch: use ipgre tunnel rather
 than gretap tunnel
Date: Wed, 19 Oct 2016 18:58:39 +0200
Message-ID: <20161019185839.7c62183c@griffin>
References: <cover.1476708212.git.jbenc@redhat.com>
        <4e5bfb307ee1e419f973a100e8acc7556311b64a.1476708213.git.jbenc@redhat.com>
        <CAOrHB_AWT1zp_6wJMOP=2GdJGtgZ6yvt5ysf9gBBnGDKHU3BUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45972 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941180AbcJSQ6n (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Oct 2016 12:58:43 -0400
In-Reply-To: <CAOrHB_AWT1zp_6wJMOP=2GdJGtgZ6yvt5ysf9gBBnGDKHU3BUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Oct 2016 22:14:06 -0700, Pravin Shelar wrote:
> This is OVS tunnel compatibility code. We are not suppose to add new
> features to compat code. Just provide a way to configure such device
> over rtnl.

Makes sense. Please consider this a test-only patch for now. I won't
include it in v13.

rtnetlink already supports configuration of such devices, I added that
some time ago. We'll just need to make the user space aware of that.
But at the kernel side, just dropping this patch is enough.

 Jiri
