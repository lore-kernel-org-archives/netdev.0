From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.20-rc5 1/7] ehea: Fixed wrong dereferencation
Date: Tue, 23 Jan 2007 00:59:42 -0500
Message-ID: <45B5A44E.9020703@garzik.org>
References: <200701221252.20814.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <ossthema@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <roscher@de.ibm.com>,
	Stefan Roscher <ossrosch@de.ibm.com>,
	Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45504 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933008AbXAWF7s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 00:59:48 -0500
To: Thomas Klein <osstklei@de.ibm.com>
In-Reply-To: <200701221252.20814.osstklei@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Klein wrote:
> Not only check the pointer against 0 but also the dereferenced value
> 
> Signed-off-by: Thomas Klein <tklein@de.ibm.com>
> ---
> 
> 
>  drivers/net/ehea/ehea.h      |    2 +-
>  drivers/net/ehea/ehea_main.c |    6 ++++--
>  2 files changed, 5 insertions(+), 3 deletions(-)

applied 1-7 to #upstream-fixes

