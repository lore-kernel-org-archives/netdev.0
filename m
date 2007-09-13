From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.18-rc6 1/2] dllink driver: porting v1.19 to linux
 2.6.18-rc6
Date: Thu, 13 Sep 2007 00:00:07 -0400
Message-ID: <46E8B5C7.8060804@garzik.org>
References: <1157620189.2904.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	edward_peng@dlink.com.tw, linux-kernel@vger.kernel.org
To: Hayim Shaul <hayim@iportent.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40630 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750729AbXIMEAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 00:00:11 -0400
In-Reply-To: <1157620189.2904.16.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayim Shaul wrote:
> Description:
> For DLink Fiber NIC, Linux 2.4.22 ships with driver version 1.19,
> whereas, Linux 2.6.x ship with driver version 1.17.
> 
> The following patch upgrades the 2.6.x driver to include changes (and
> bug fixes done until 1.19b).
> 
> These fixes are (copied from the driver):
>     1.18    2002/11/07  New tx scheme, adaptive tx_coalesce.
>                     Remove tx_coalesce option.
>     1.19    2003/12/16  Fix problem parsing the eeprom on big endian
>                     systems. (philt@4bridgeworks.com)
> 
> Disclaimer:
> Since I returned my DLink NIC to the store I couldn't test it
> thoroughly. It seemed to work just as well as v1.17. However, both
> version made the NIC hang after a few minutes.

Please update to the latest upstream kernel (2.6.22 or 2.6.23-rc).

Also, please make sure you do not back out changes included in the 
upstream kernel since 2.6.17.


