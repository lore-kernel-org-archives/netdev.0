From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [2.6.19 PATCH 3/7] ehea: queue management
Date: Fri, 18 Aug 2006 14:17:31 +0200
Message-ID: <1155903451.4494.168.camel@laptopd505.fenrus.org>
References: <200608181331.19501.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <osstklei@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:17047 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1030349AbWHRMRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 08:17:53 -0400
To: Jan-Bernd Themann <ossthema@de.ibm.com>
In-Reply-To: <200608181331.19501.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +	queue->queue_length = nr_of_pages * pagesize;
> +	queue->queue_pages = vmalloc(nr_of_pages * sizeof(void *));


wow... is this really so large that it warrants a vmalloc()???


