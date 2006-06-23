From: John Daiker <jdaiker@osdl.org>
Subject: Kernel Janitor TODO: dev_kfree_skb
Date: Fri, 23 Jun 2006 10:35:53 -0700
Message-ID: <449C2679.6020501@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:5345 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751816AbWFWRf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 13:35:58 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I was running through the kernel janitors TODO list 
(http://janitor.kernelnewbies.org/TODO) and thought I'd try to find 
something easy for my first attempt at kernel hacking/maintenance.

The "Balancing Function" header suggests that all net_device interrupt 
functions should use dev_kfree_skb_irq as opposed to dev_kfree_skb.
Should we ever be calling dev_kfree_skb directly, or would the better 
practice be to always call dev_kfree_skb_any (thus letting the kernel 
decide to call dev_kfree_skb or dev_kfree_skb_irq)?

dev_kfree_skb_any is defined in 'net/core/dev.c:1118'

John Daiker
