From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] eHEA: Introducing support vor DLPAR memory add
Date: Mon, 16 Jul 2007 17:59:59 -0400
Message-ID: <469BEA5F.5050508@garzik.org>
References: <200707111632.00235.osstklei@de.ibm.com>
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
	Stefan Roscher <ossrosch@linux.vnet.ibm.com>
To: Thomas Klein <osstklei@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37008 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756371AbXGPWAF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 18:00:05 -0400
In-Reply-To: <200707111632.00235.osstklei@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Klein wrote:
> This patch adds support for DLPAR memory add to the eHEA driver. To detect
> whether memory was added the driver uses its own memory mapping table and
> checks for kernel addresses whether they're located in already known memory
> sections. If not the function ehea_rereg_mrs() is triggered which performs
> a rebuild of the mapping table and a re-registration of the global memory
> region.
> 
> Signed-off-by: Thomas Klein <tklein@de.ibm.com>
> ---
> 
>  drivers/net/ehea/ehea.h      |   23 +++++--
>  drivers/net/ehea/ehea_main.c |  144 +++++++++++++++++++++++++++++++++++----
>  drivers/net/ehea/ehea_phyp.h |    3 +
>  drivers/net/ehea/ehea_qmr.c  |  156 ++++++++++++++++++++++++++++++------------
>  drivers/net/ehea/ehea_qmr.h  |   14 +++-
>  5 files changed, 275 insertions(+), 65 deletions(-)

applied


