From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [net-next PATCH 04/10] pktgen: document ability to add same device
 to several threads
Date: Tue, 19 May 2015 14:54:13 -0700
Message-ID: <555BB105.8060307@plumgrid.com>
References: <20150519213326.9070.18264.stgit@ivy> <20150519213548.9070.25035.stgit@ivy>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:32832 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617AbbESVyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 17:54:15 -0400
Received: by padbw4 with SMTP id bw4so41163310pad.0
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 14:54:14 -0700 (PDT)
In-Reply-To: <20150519213548.9070.25035.stgit@ivy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/19/15 2:35 PM, Jesper Dangaard Brouer wrote:
> The pktgen.txt documentation still claimed that adding same device to
> multiple threads were not supported, but it have been since 2008 via
> commit e6fce5b916cd7 ("pktgen: multiqueue etc.").
>
> Document this and describe the naming scheme dev@X, as the procfile name
> still need to be unique.
>
> Fixes: e6fce5b916cd7 ("pktgen: multiqueue etc.")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
...
> -Most important are the devices assigned to the thread.  Note that a
> -device can only belong to one thread.
> +The two basic thread commands are:
> + * add_device DEVICE@NAME -- adds a single device

Great work for the whole series!
Wanted to specifically
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
this patch, since it could have saved me days of pointlessly
reimplementing existing feature and likely will help others
in the future. People do read docs :)
