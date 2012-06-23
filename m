From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/3 net-next] tg3: Add sysfs file to export sensor data
Date: Fri, 22 Jun 2012 17:59:34 -0700
Message-ID: <20120622175934.2cc253b7@nehalam.linuxnetplumber.net>
References: <1340237192-30052-1-git-send-email-mchan@broadcom.com>
	<1340237192-30052-2-git-send-email-mchan@broadcom.com>
	<1340237192-30052-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, nsujir@broadcom.com,
	mcarlson@broadcom.com
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46320 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756846Ab2FWA7i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jun 2012 20:59:38 -0400
In-Reply-To: <1340237192-30052-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Jun 2012 17:06:32 -0700
"Michael Chan" <mchan@broadcom.com> wrote:

> Some tg3 devices have management firmware that can export data such as
> temperature and other real time diagnostics data.  Export this data to
> sysfs so that userspace can access this information.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Linux has existing sensor api's that can be used by existing
services like SNMP. Wouldn't you like the it to just work with
existing code API's?
