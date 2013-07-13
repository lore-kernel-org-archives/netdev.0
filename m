From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [RFC PATCH] sctp: Don't lookup dst if transport dst is still
 valid
Date: Sat, 13 Jul 2013 08:18:42 -0400
Message-ID: <51E145A2.5080809@gmail.com>
References: <51D6D3A0.7050106@gmail.com> <51DC282C.9090007@gmail.com> <51DF74BE.6000001@windriver.com> <20130712.155808.2237731776440357524.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fan.du@windriver.com, nhorman@tuxdriver.com,
	nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f43.google.com ([209.85.128.43]:32977 "EHLO
	mail-qe0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623Ab3GMMSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jul 2013 08:18:46 -0400
Received: by mail-qe0-f43.google.com with SMTP id q19so5588957qeb.16
        for <netdev@vger.kernel.org>; Sat, 13 Jul 2013 05:18:45 -0700 (PDT)
In-Reply-To: <20130712.155808.2237731776440357524.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/2013 06:58 PM, David Miller wrote:
> From: Fan Du <fan.du@windriver.com>
> Date: Fri, 12 Jul 2013 11:15:10 +0800
>
>> But problem still arise when we attempt to delete address
>> in multi-home mode, deleting an IPv6 address does not invalidate
>> any dst which source address is the same at the deleted one.
>> Which means sctp cannot rely on ip6_dst_check in this scenario.
>
> I still cannot understand why this is an SCTP specific issue.
>
> Specifically, I cannot see why address addition/deletion doesn't
> cause problems for cached ipv6 routes in UDP and TCP sockets too.
>

Trying to figure this out.

-vlad
