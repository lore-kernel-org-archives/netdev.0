From: Breno Leitao <brenohl@br.ibm.com>
Subject: Re: [PATCH] cxgb3: Set vlan_feature on net_device
Date: Fri, 27 Jul 2012 15:57:03 -0300
Message-ID: <5012E47F.5060207@br.ibm.com>
References: <1343413351-48710-1-git-send-email-brenohl@br.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jitendra.kalsaria@qlogic.com, ron.mercer@qlogic.com,
	netdev@vger.kernel.org
To: brenohl@br.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:41884 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236Ab2G0S5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 14:57:13 -0400
Received: from /spool/local
	by e24smtp02.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <brenohl@br.ibm.com>;
	Fri, 27 Jul 2012 15:57:12 -0300
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id DCA67352004F
	for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 14:57:03 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay03.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6RIuIf724313916
	for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 15:56:18 -0300
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6RGusqv012207
	for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 13:56:55 -0300
In-Reply-To: <1343413351-48710-1-git-send-email-brenohl@br.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/27/2012 03:22 PM, brenohl@br.ibm.com wrote:
> cxgb3 interface has a bad performance when VLAN is set. On my current
> setup, a PowerLinux 7R2, I am able to get around 7 Gbps on a TCP_STREAM
> (8 instances, 4k message).
> With this patch, I am able to reach 9.5 Gbps.
Please do not consider this patch. I'd send a qlge patch, but wrongly made
a shell-completion mistake and sent the wrong patch. The correct patch is
under its way.
