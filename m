From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irlan: fix header build warning
Date: Wed, 06 Dec 2006 16:57:17 -0800 (PST)
Message-ID: <20061206.165717.21938171.davem@davemloft.net>
References: <20061206114407.9b835a7a.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42057
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S937869AbWLGA5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 19:57:06 -0500
To: randy.dunlap@oracle.com
In-Reply-To: <20061206114407.9b835a7a.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Wed, 6 Dec 2006 11:44:07 -0800

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix compile warning when CONFIG_PROC_FS=n:
> 
> include/net/irda/irlan_filter.h:31: warning: 'struct seq_file' declared inside parameter list
> include/net/irda/irlan_filter.h:31: warning: its scope is only this definition or declaration, which is probably not what you want
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

How about we protect these function externs with CONFIG_PROC_FS ifdefs
instead?
