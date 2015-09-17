From: Rick Jones <rick.jones2@hp.com>
Subject: Re: list of all network namespaces
Date: Wed, 16 Sep 2015 17:54:34 -0700
Message-ID: <55FA0F4A.3010105@hp.com>
References: <CAOxq_8Noj5oxPY5BEsWL6u4h_AD+oXYS+JCRGES_gmMQKd0rOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Ani Sinha <ani@arista.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t4625.austin.hp.com ([15.73.212.76]:58719 "EHLO
	g2t4625.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752822AbbIQBBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 21:01:02 -0400
Received: from g2t4619.austin.hp.com (g2t4619.austin.hp.com [15.73.212.82])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g2t4625.austin.hp.com (Postfix) with ESMTPS id 0FFFE612A
	for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 00:54:36 +0000 (UTC)
In-Reply-To: <CAOxq_8Noj5oxPY5BEsWL6u4h_AD+oXYS+JCRGES_gmMQKd0rOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/16/2015 05:46 PM, Ani Sinha wrote:
> Hi guys
>
> just a stupid question. Is it possible to get a list of all active
> network namespaces in the kernel through /proc or some other
> interface?

Presumably you could copy what "ip netns" does, which appears to be to 
look in /var/run/netns .  At least that is what an strace of that 
command suggests.

rick jones
