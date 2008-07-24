From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] IPVS: Move userspace definitions to include/linux/ip_vs.h
Date: Thu, 24 Jul 2008 12:09:37 +0200
Message-ID: <f4845fc0807240309l73ce2ab3qe047ead5c6f1f52c@mail.gmail.com>
References: <20080722003755.GA7962@verge.net.au>
	 <20080723.164215.101337333.davem@davemloft.net>
	 <20080724002057.GA3032@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org, kaber@trash.net, vbusam@google.com
To: "Simon Horman" <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:49782 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751997AbYGXKJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 06:09:41 -0400
Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id m6OA9cfb013744
	for <netdev@vger.kernel.org>; Thu, 24 Jul 2008 11:09:39 +0100
Received: from wf-out-1314.google.com (wfc28.prod.google.com [10.142.3.28])
	by zps77.corp.google.com with ESMTP id m6OA9buD019028
	for <netdev@vger.kernel.org>; Thu, 24 Jul 2008 03:09:38 -0700
Received: by wf-out-1314.google.com with SMTP id 28so2451547wfc.11
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2008 03:09:37 -0700 (PDT)
In-Reply-To: <20080724002057.GA3032@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2008 at 2:20 AM, Simon Horman <horms@verge.net.au> wrote:
> On Wed, Jul 23, 2008 at 04:42:15PM -0700, David Miller wrote:
>> Userland exported headers need to have an entry in include/linux/Kbuild
>>
>> Since this linux/ip_vs.h file is new, a new entry needs to be added there.
>
> Thanks, I wasn't aware of that.

Oh, me neither.

> Julius, I think this is the bit we are missing:
>
> Index: net-next-2.6/include/linux/Kbuild
> ===================================================================
> --- net-next-2.6.orig/include/linux/Kbuild      2008-07-24 10:15:52.000000000 +1000
> +++ net-next-2.6/include/linux/Kbuild   2008-07-24 10:19:08.000000000 +1000
> @@ -97,6 +97,7 @@ header-y += ioctl.h
>  header-y += ip6_tunnel.h
>  header-y += ipmi_msgdefs.h
>  header-y += ipsec.h
> +header-y += ip_vs.h
>  header-y += ipx.h
>  header-y += irda.h
>  header-y += iso_fs.h

Thanks, I'll post the patch again with this!

Julius

-- 
Google Switzerland GmbH
