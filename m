From: "Denis V. Lunev" <dlunev@gmail.com>
Subject: Re: [NET] IPv6 oops bisected
Date: Sun, 07 Oct 2007 17:49:03 +0400
Message-ID: <4708E3CF.4000401@gmail.com>
References: <4708D677.1030601@garzik.org> <4708E016.9020300@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, den@openvz.org,
	David Miller <davem@davemloft.net>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:62061 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581AbXJGNrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2007 09:47:35 -0400
Received: by ug-out-1314.google.com with SMTP id z38so670122ugc
        for <netdev@vger.kernel.org>; Sun, 07 Oct 2007 06:47:34 -0700 (PDT)
In-Reply-To: <4708E016.9020300@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Jeff Garzik wrote:
>> The commit
>>
>> commit 5f5dace1ce001b24fb8286e09ffd3c4d2b547e09
>> Author: Denis V. Lunev <den@openvz.org>
>> Date:   Thu Sep 27 12:41:26 2007 -0700
>>
>>     [NET]: Various dst_ifdown routines to catch refcounting bugs
>>
>> causes a 100% reproducible oops in net-2.6.24.git, in ip6_route_add().
>>
>> Platform: x86-64 Fedora 7
>>
>> Config and lspci attached.
> 
> And indeed, reverting this commit with 'patch -R' makes things work again.
> 
>     Jeff

Can you me command to execute to reproduce the problem? and oops if
possible.

Regards,
	Den
