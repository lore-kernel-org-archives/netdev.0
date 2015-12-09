From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] net: Add fib rules at vrf device create
Date: Tue, 8 Dec 2015 20:21:51 -0700
Message-ID: <56679E4F.3020908@cumulusnetworks.com>
References: <1449607685-8910-1-git-send-email-dsa@cumulusnetworks.com>
 <20151208.214411.2137019448940208712.davem@davemloft.net>
 <56679B2F.5080700@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: David Ahern <dsa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33154 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbbLIDVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 22:21:54 -0500
Received: by pabur14 with SMTP id ur14so22317490pab.0
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 19:21:53 -0800 (PST)
In-Reply-To: <56679B2F.5080700@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/8/15 8:08 PM, David Ahern wrote:
> root@kenny-jessie2:~# ip ru add oif vrf-red lookup vrf-red
>
> root@kenny-jessie2:~# ip ru ls
> 0:    from all lookup local
> 32759:    from all oif vrf-red lookup vrf-red
> 32760:    from all iif vrf-green lookup vrf-green
> 32761:    from all oif vrf-green lookup vrf-green
> 32762:    from all iif vrf-blue lookup vrf-blue
> 32763:    from all oif vrf-blue lookup vrf-blue
> 32764:    from all iif vrf-red lookup vrf-red
> 32765:    from all oif vrf-red lookup vrf-red
> 32766:    from all lookup main
> 32767:    from all lookup default

d'oh. They don't fail in the sense of a user getting an error message 
but they add duplicate entries. So, if I fix the duplicity (ie., don't 
add a second one) would the patch be acceptable?
