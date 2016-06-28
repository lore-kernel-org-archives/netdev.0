From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 08/16] net/devlink: Add E-Switch mode control
Date: Tue, 28 Jun 2016 14:27:51 +0200
Message-ID: <20160628122751.GA2089@nanopsycho.orion>
References: <1467043649-28594-1-git-send-email-saeedm@mellanox.com>
 <1467043649-28594-9-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34571 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752710AbcF1M1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 08:27:55 -0400
Received: by mail-wm0-f68.google.com with SMTP id 187so5577274wmz.1
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2016 05:27:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1467043649-28594-9-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jun 27, 2016 at 06:07:21PM CEST, saeedm@mellanox.com wrote:
>From: Or Gerlitz <ogerlitz@mellanox.com>
>
>Add the commands to set and show the mode of SRIOV E-Switch,
>two modes are supported:
>
>* legacy   : operating in the "old" L2 based mode (DMAC --> VF vport)
>* offloads : offloading SW rules/policy (e.g Bridge/FDB or TC/Flows based) set by the host OS
>
>Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>

Looks fine to me. Usable for many drivers of devices containing embedded
switch. We need this for clean transition from legacy handling of embedded
switches we have in drivers currently to new switchdev model.

Thanks!
