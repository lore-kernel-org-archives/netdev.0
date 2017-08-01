From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: Re: [PATCH V2 net-next 0/2] liquidio: Add support for managing
 liquidio adapter
Date: Mon, 31 Jul 2017 19:09:08 -0700
Message-ID: <20170801020908.GB1449@felix-thinkpad.cavium.com>
References: <20170729061707.GA1134@felix-thinkpad.cavium.com>
 <20170730202103.GA8969@vergenet.net>
 <20170731.175937.1373949013417491840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: simon.horman@netronome.com, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, veerasenareddy.burru@cavium.com,
        jakub.kicinski@netronome.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0053.outbound.protection.outlook.com ([104.47.38.53]:62544
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751296AbdHACJk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 22:09:40 -0400
Content-Disposition: inline
In-Reply-To: <20170731.175937.1373949013417491840.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 31, 2017 at 05:59:37PM -0700, David Miller wrote:
> From: Simon Horman <simon.horman@netronome.com>
> Date: Sun, 30 Jul 2017 22:21:04 +0200
> 
> > On Fri, Jul 28, 2017 at 11:17:07PM -0700, Felix Manlunas wrote:
> >> From: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>
> >> 
> >> The LiquidIO adapter has processor cores that can run Linux. This patch
> >> set adds support to create a virtual Ethernet interface on host to
> >> communicate with applications running on Linux in the LiquidIO adapter.
> >> The virtual Ethernet interface also provides login access to Linux on
> >> LiquidIO through ssh for management and debugging.
> > 
> > As per the somewhat more detailed feedback provided by my colleague Jakub
> > Kicinski to v1 of this patchset[1] I am concerned that this patchset breaks down
> > the long standing practice of not granting direct access to firmware from
> > userspace.
> > 
> > [1] https://www.spinics.net/lists/netdev/msg444929.html
> 
> Agreed, I've seen no attempt to address this important feedback, which
> I agree with.

We posted a response to the original comment on Friday 28-July.
but for some reason, it did not make to the mailing list outside
cavium domain. our apologies, we did not double check before submitting
V2 patch. Please find below the response reposted on original thread

http://marc.info/?l=linux-netdev&m=150155273724386&w=2
