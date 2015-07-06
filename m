From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC net-next 0/6] Proposal for VRF-lite - v2
Date: Mon, 06 Jul 2015 17:40:55 +0200
Message-ID: <559AA187.6000007@6wind.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, stephen@networkplumber.org,
	hadi@mojatatu.com, ebiederm@xmission.com, davem@davemloft.net
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36494 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753686AbbGFPk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 11:40:58 -0400
Received: by widjy10 with SMTP id jy10so164609949wid.1
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 08:40:57 -0700 (PDT)
In-Reply-To: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/07/2015 17:03, David Ahern a =C3=A9crit :
> In the context of internet scale routing a requirement that always
> comes up is the need to partition the available routing tables into
> disjoint routing planes. A specific use case is the multi-tenancy
> problem where each tenant has their own unique routing tables and in
> the very least need different default gateways.
>
> This is an attempt to build the ability to create virtual router
> domains aka VRF's (VRF-lite to be specific) in the linux packet
> forwarding stack. The main observation is that through the use of
> rules and socket binding to interfaces, all the facilities that we
> need are already present in the infrastructure. What is missing is a
> handle that identifies a routing domain and can be used to gather
> applicable rules/tables and uniqify neighbor selection. The scheme
> used needs to preserves the notions of ECMP, and general routing
> principles.
[snip]
>   drivers/net/vrf.c             | 486 +++++++++++++++++++++++++++++++=
+++++++++++
[snip]

I'm still opposed to name this 'vrf', see the v1 thread:
  - http://www.spinics.net/lists/netdev/msg332357.html
  - http://www.spinics.net/lists/netdev/msg332376.html

Shrijeet seemed to agree to rename it, is there a problem?


Regards,
Nicolas
