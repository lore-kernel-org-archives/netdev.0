From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next V2 08/16] net/devlink: Add E-Switch mode control
Date: Thu, 30 Jun 2016 17:45:56 -0700
Message-ID: <5775BD44.7080906@gmail.com>
References: <1467300215-14199-1-git-send-email-saeedm@mellanox.com>
 <1467300215-14199-9-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:36470 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052AbcGAAxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 20:53:45 -0400
Received: by mail-oi0-f45.google.com with SMTP id f189so90484093oig.3
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 17:53:45 -0700 (PDT)
In-Reply-To: <1467300215-14199-9-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-30 08:23 AM, Saeed Mahameed wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> 
> Add the commands to set and show the mode of SRIOV E-Switch, two modes
> are supported:
> 
> * legacy: operating in the "old" L2 based mode (DMAC --> VF vport)
> 
> * switchdev: the E-Switch is referred to as whitebox switch configured
> using standard tools such as tc, bridge, openvswitch etc. To allow
> working with the tools, for each VF, a VF representor netdevice is
> created by the E-Switch manager vendor device driver instance (e.g PF).
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---


OK I can't come up with a better name and Jiri/Or convinced me this
should work ok so this works for me.

One question though going forward. We have devices with multiple
"switches" in them how does this work in a devlink environment? Do
we need some way to enumerate the switches and identify them. In
which case this attribute would be a global setting.

Thanks,
John
