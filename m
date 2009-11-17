From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH iproute2] ip: Add support for setting MAC and VLAN
 on hardware queues
Date: Tue, 17 Nov 2009 14:06:41 -0800
Message-ID: <20091117140641.7f8c8ac0@nehalam>
References: <20091117215432.15195.94504.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49914 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753358AbZKQWGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2009 17:06:41 -0500
In-Reply-To: <20091117215432.15195.94504.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Nov 2009 13:55:07 -0800
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> From: Williams, Mitch A <mitch.a.williams@intel.com>
> 
> This patch adds support to the "ip" tool for setting the MAC address and
> VLAN filter for hardware device queues. This is most immediately useful for
> SR-IOV; for VF devices to be usable in the real world, the hypervisor or VM
> manager must be able to set these parameters before the VF device is
> assigned to any VM.
> 
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Is there anything to avoid prevent this from being misused by users who
are doing multiqueue. Maybe we need equivalent of "mounted" flag that block
devices have?
