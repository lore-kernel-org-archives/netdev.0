From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: Update vxlan fdb 'used' field after each usage.
Date: Thu, 16 May 2013 15:00:19 -0700 (PDT)
Message-ID: <20130516.150019.1779890463663876284.davem@davemloft.net>
References: <1368723943.14093.4.camel@sridhar.usor.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, dlstevens@us.ibm.com,
	netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55679 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959Ab3EPWAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 18:00:20 -0400
In-Reply-To: <1368723943.14093.4.camel@sridhar.usor.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Thu, 16 May 2013 10:05:43 -0700

> Fix some instances where vxlan fdb 'used' field is not updated after the entry 
> is used.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Please just put the ->used update into vxlan_find_mac().

Thanks.
