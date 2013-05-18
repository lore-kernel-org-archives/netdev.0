From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] vxlan: Update vxlan fdb 'used' field after each
 usage
Date: Sat, 18 May 2013 12:54:13 -0700 (PDT)
Message-ID: <20130518.125413.2212196082668315384.davem@davemloft.net>
References: <1368808747.14093.23.camel@sridhar.usor.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, dlstevens@us.ibm.com,
	netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085Ab3ERTyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 May 2013 15:54:14 -0400
In-Reply-To: <1368808747.14093.23.camel@sridhar.usor.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Fri, 17 May 2013 09:39:07 -0700

> Fix some instances where vxlan fdb 'used' field is not updated after the entry 
> is used.
> 
> v2: rename vxlan_find_mac() as __vxlan_find_mac() and create a new vxlan_find_mac()
> that also updates ->used field.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Looks good, applied, thanks!
