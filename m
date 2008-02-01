From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ehea: fix sysfs link compile problem
Date: Fri, 01 Feb 2008 13:40:46 -0500
Message-ID: <47A367AE.8000004@garzik.org>
References: <200802011537.42578.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	netdev <netdev@vger.kernel.org>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54890 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755013AbYBASks (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 13:40:48 -0500
In-Reply-To: <200802011537.42578.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan-Bernd Themann wrote:
> Due to changes in the struct device_driver there is no direct
> access to its kobj any longer. The kobj was used to create
> sysfs links between eHEA ethernet devices and the driver.
> This patch removes the affected sysfs links to resolve
> the build problems.
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
> 
> 
> ---
>  drivers/net/ehea/ehea_main.c |   37 -------------------------------------
>  1 files changed, 0 insertions(+), 37 deletions(-)

applied


