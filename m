From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] netxen: sparse warning and ioctl bug fixes
Date: Wed, 6 Dec 2006 08:30:36 -0800
Message-ID: <20061206083036.3de22974@localhost.localdomain>
References: <20061205120717.2e362ddf@freekitty>
	<200612062140.35176.amitkale@linsyssoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Amit S. Kale" <amitkale@netxen.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:40388 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936393AbWLFQbg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Dec 2006 11:31:36 -0500
To: "Amit S. Kale" <amitkale@linsyssoft.com>
In-Reply-To: <200612062140.35176.amitkale@linsyssoft.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 6 Dec 2006 21:40:34 +0530
"Amit S. Kale" <amitkale@linsyssoft.com> wrote:

> Hi Stephen,
> 
> This patch looks good. 
> 
> ioctls: NetXen chip is far more generic and will eventually show a significant 
> amount of functionality in different products. We need ioctl analysis for 
> user level tools that can tell states of registers etc. Removing ioctls all 
> together will make any analysis from userland extremely difficult.

Use (and extend) existing ethtool interface to get registers and statistics.


> 
> Does anyone have ideas on improving this ioctl interface?
> 
> Thanks.
> -Amit
> 
