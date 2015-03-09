From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 2/8] netdevice: add IPv4 fib add/del ops
Date: Mon, 09 Mar 2015 09:47:04 -0400
Message-ID: <54FDA458.6040601@mojatatu.com>
References: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>	<1425619280-27492-3-git-send-email-sfeldma@gmail.com>	<54F9BFCB.5030100@mojatatu.com> <CAE4R7bAcfJ8M0eQMdZdS3aDgPVWSQznABZymGq+PU34vJx1suA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:46876 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754248AbbCINrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 09:47:08 -0400
Received: by iecrd18 with SMTP id rd18so12293219iec.13
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 06:47:07 -0700 (PDT)
In-Reply-To: <CAE4R7bAcfJ8M0eQMdZdS3aDgPVWSQznABZymGq+PU34vJx1suA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/15 14:59, Scott Feldman wrote:
>
> I considered passing netlink flags in to driver, but the kernel logic
> in fib_table_insert() already takes care of the checks required by the
> flags, and from the driver's perspective, only three ops are needed:
> add, del, and mod.  And I've combined add and mod into the same op,
> with the assumption the driver can know if an entry exists or not.
>

That assumption is not accurate. At least in some hardware i am working
on right now a mod is cheaper than a create (and if i have to "know"
wheter i should create or modify then i actually i have to query the
hardware).

cheers,
jamal
