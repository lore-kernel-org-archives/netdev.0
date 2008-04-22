From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: miss section in menuconfig generator?
Date: Tue, 22 Apr 2008 14:12:04 +0400
Message-ID: <480DB9F4.2010809@bigtelecom.ru>
References: <480DB039.3040906@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:35211 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754982AbYDVKMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 06:12:13 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 875C7A6C59B
	for <netdev@vger.kernel.org>; Tue, 22 Apr 2008 14:12:11 +0400 (MSD)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id dUEvcMRuUcvG for <netdev@vger.kernel.org>;
	Tue, 22 Apr 2008 14:12:05 +0400 (MSD)
Received: from [87.255.0.131] (slavon.bigtelecom.ru [87.255.0.131])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 994A0A6C159
	for <netdev@vger.kernel.org>; Tue, 22 Apr 2008 14:12:05 +0400 (MSD)
In-Reply-To: <480DB039.3040906@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I found.
its becouse in file ./net/ipv4/netfilter/Kconfig all this options have 
NULL "tristate" like this:

config NF_NAT_PROTO_GRE
        tristate
        depends on NF_NAT && NF_CT_PROTO_GRE

Is that normal? How to compile that parts in kernel (not modules)?

Thanks!

> Hello all. Sorry if its not bug.
>
> look to section "IP: Netfilter Configuration" in .config i see values 
> like this:
> CONFIG_NF_NAT_PROTO_GRE=m
>
> but in menuconfig i can find it in this section ("network->Network 
> packet filtering framework->IP: Netfilter Configuration"). its 
> blackhole? =)
>
> I attach my config.
>
> Thanks all
>

