From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH 0/12] L2 network namespace (v3)
Date: Wed, 17 Jan 2007 16:58:17 +0100
Message-ID: <45AE4799.6000605@fr.ibm.com>
References: <200701171851.14734.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, alexey@sw.ru, saw@sw.ru,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:3234 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbXAQP6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jan 2007 10:58:21 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l0HFwKcB036116
	for <netdev@vger.kernel.org>; Wed, 17 Jan 2007 15:58:20 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0HFwJi52469974
	for <netdev@vger.kernel.org>; Wed, 17 Jan 2007 16:58:19 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0HFwII6018409
	for <netdev@vger.kernel.org>; Wed, 17 Jan 2007 16:58:19 +0100
To: Dmitry Mishin <dim@openvz.org>
In-Reply-To: <200701171851.14734.dim@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry Mishin wrote:
> This is an update of L2 network namespaces patches. They are applicable
> to Cedric's 2.6.20-rc4-mm1-lxc2 tree. 
> 
> Changes:
> 	- updated to 2.6.20-rc4-mm1-lxc2
> 	- current network context is per-CPU now
> 	- fixed compilation without CONFIG_NET_NS
> 
> Changed current context definition should fix all mentioned by Cedric issues:
> 	- the nsproxy backpointer is unnecessary now - thus removed; 
> 	- the push_net_ns() and pop_net_ns() use per-CPU variable now;
> 	- there is no race on ->nsproxy between push_net_ns() and
> 	  exit_task_namespaces() because they deals with differrent pointers.

great ! Will integrate ASAP with daniel l3 patches and resend.

thanks,

C.
