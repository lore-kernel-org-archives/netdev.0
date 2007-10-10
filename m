From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ehea: use kernel event queue
Date: Tue, 09 Oct 2007 20:39:31 -0400
Message-ID: <470C1F43.7050608@garzik.org>
References: <200710081601.34067.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Anton Blanchard <anton@samba.org>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39083 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752994AbXJJAjj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 20:39:39 -0400
In-Reply-To: <200710081601.34067.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan-Bernd Themann wrote:
> eHEA recovery and DLPAR functions are called seldomly. The eHEA workqueues
> are replaced by the kernel event queue.
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
> 
> ---
> The patch has been built against upstream git
> 
>  drivers/net/ehea/ehea.h      |    3 +--
>  drivers/net/ehea/ehea_main.c |   28 ++++++++--------------------
>  drivers/net/ehea/ehea_qmr.c  |    3 +--
>  3 files changed, 10 insertions(+), 24 deletions(-)

applied


