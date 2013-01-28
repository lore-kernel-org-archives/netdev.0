From: Stefan Assmann <sassmann@redhat.com>
Subject: Re: [net-next 14/14] igbvf: be sane about random MAC addresses
Date: Mon, 28 Jan 2013 12:11:22 +0100
Message-ID: <51065CDA.90307@redhat.com>
References: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com> <1359363869-32391-15-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Andy Gospodarek <andy@greyhouse.net>,
	Stefan Assmann <sassmann@kpanic.de>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60181 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754205Ab3A1LL2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 06:11:28 -0500
In-Reply-To: <1359363869-32391-15-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28.01.2013 10:04, Jeff Kirsher wrote:
> From: Mitch A Williams <mitch.a.williams@intel.com>
> 
> Tighten up some of the code surrounding MAC addresses. Since the PF is
> now giving all zeros instead of a random address, check for this case
> and generate a random address. This ensures that we always know when we
> have a random address and udev won't get upset about it.
> 
> Additionally, tighten up some of the log messages and clean up the
> formatting.
> 
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: Stefan Assmann <sassmann@kpanic.de>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Tested-by: Stefan Assmann <sassmann@redhat.com>

Thanks Mitch. This solves the problem of correctly setting
addr_assign_type.

  Stefan
