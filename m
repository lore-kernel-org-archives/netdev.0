From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC 1/2] [IPV6] ADDRCONF: Preparation for configurable address
 selection policy with ifindex.
Date: Tue, 30 Oct 2007 13:34:21 +0530
Message-ID: <OF6038860D.3DC5CB4E-ON65257384.002B94CE-65257384.002C5812@in.ibm.com>
References: <20071030.145237.68878443.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP02.au.ibm.com ([202.81.18.163]:56457 "EHLO
	e23smtp02.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbXJ3ItN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 04:49:13 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9U82dXe011245
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 19:02:39 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9U86ETg156824
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 19:06:15 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9U82NeF029783
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 19:02:23 +1100
In-Reply-To: <20071030.145237.68878443.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Yoshifuji,

YOSHIFUJI Hideaki wrote on 10/30/2007 11:22:37 AM:

> -static inline int ipv6_saddr_label(const struct in6_addr *addr, int
type)
> +static inline int ipv6_addr_label(const struct in6_addr *addr, int type,
> +                                                int ifindex)

This function doesn't use this new argument passed to it. Did you perhaps
intend to use it to
initializing daddr_index?

> +   int daddr_ifindex = daddr_dev ? daddr_dev->ifindex : 0;

Thanks,

- KK

