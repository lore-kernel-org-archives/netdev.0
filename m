From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] eHEA: Receive SKB Aggregation
Date: Tue, 10 Jul 2007 13:00:18 -0400
Message-ID: <4693BB22.5070303@garzik.org>
References: <200707041209.48658.ossthema@de.ibm.com>
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
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60411 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759974AbXGJRAU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 13:00:20 -0400
In-Reply-To: <200707041209.48658.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan-Bernd Themann wrote:
> This patch enables the receive side processing to aggregate TCP packets within
> the HEA device driver. It analyses the packets already received after an
> interrupt arrived and forwards these as chains of SKBs for the same TCP
> connection with modified header field. We have seen a lower CPU load and
> improved throughput for small numbers of parallel TCP connections.
> As this feature is considered as experimental it is switched off by default
> and can be activated via a module parameter.
> 
> Some additional security checks have been added since the last posting.
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

as noted in comments, we don't need to recreate this in every driver. 
do something more generic.


