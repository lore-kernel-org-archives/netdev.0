From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net 2/2] cxgb4: Disable interrupts and napi before unregistering
 netdev
Date: Thu, 26 Mar 2015 22:02:14 +0100
Message-ID: <551473D6.2050406@gmx.de>
References: <1427344466-17658-1-git-send-email-hariprasad@chelsio.com> <1427344466-17658-3-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com
To: Hariprasad Shenai <hariprasad@chelsio.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:55165 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752632AbbCZVCY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2015 17:02:24 -0400
In-Reply-To: <1427344466-17658-3-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 26.03.2015 05:34, Hariprasad Shenai wrote:
> Disable interrupts and quiesce rx before unregistering net device to avoid crash
> while unloading driver when traffic is flowing through.
> 
> Based on original work by Shameem Khalid <shameem@chelsio.com>
> 

just out of curiousity: How can an unregister of a netdevice lead to a
crash caused by traffic? I understand that _freeing_ the device or other
resources is a bad idea as long as irqs are still active. But unregister
should not do anything critical (i am asking since I want to avoid such
problems in my own drivers).

Regards,
Lino
