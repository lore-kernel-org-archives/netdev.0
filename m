From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 01/11] e1000: memory leak in e1000_set_ringparam()
Date: Mon, 25 Sep 2006 20:02:17 -0400
Message-ID: <45186E09.1080003@garzik.org>
References: <200609252339.k8PNdFO1002622@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vvs@sw.ru, auke-jan.h.kok@intel.com,
	cramerj@intel.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:25816 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751805AbWIZACV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 20:02:21 -0400
To: akpm@osdl.org
In-Reply-To: <200609252339.k8PNdFO1002622@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Vasily Averin <vvs@sw.ru>
> 
> Memory leak was found in 2.6.18-rc4 and e1000 7.2.7 from sourceforge:
> Memory allocated for new tx_ring and rx_ring leaks if
> e1000_setup_XX_resources() fails.c Also this patch reduces stack usage
> (removed tx_new and rx_new) and uses kzalloc instead kmalloc+memset(0)
> 
> Signed-off-by: Vasily Averin <vvs@sw.ru>
> Cc: Jeb Cramer <cramerj@intel.com>
> Cc: John Ronciak <john.ronciak@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Auke Kok <auke-jan.h.kok@intel.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

ACK + HOLD, waiting to see if this will be included in Auke's push

