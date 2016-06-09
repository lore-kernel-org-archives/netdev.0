From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: vrf: Add IFF_NO_QUEUE flag
Date: Wed, 8 Jun 2016 19:31:51 -0600
Message-ID: <2fb324b8-e107-3ed9-16e2-0cf59937081d@cumulusnetworks.com>
References: <1465412931-29567-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34659 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423067AbcFIBby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 21:31:54 -0400
Received: by mail-pa0-f53.google.com with SMTP id bz2so7577821pad.1
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 18:31:53 -0700 (PDT)
Received: from [172.27.227.234] ([216.129.126.118])
        by smtp.googlemail.com with ESMTPSA id ih15sm5117595pab.38.2016.06.08.18.31.52
        for <netdev@vger.kernel.org>
        (version=TLSv1/SSLv3 cipher=OTHER);
        Wed, 08 Jun 2016 18:31:52 -0700 (PDT)
In-Reply-To: <1465412931-29567-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/8/16 1:08 PM, David Ahern wrote:
> Getting the following splat with ping in a VRF:

...

> Fix by adding the IFF_NO_QUEUE flag for VRF devices.
>
> Fixes: f9eb8aea2a1e ("net_sched: transform qdisc running bit into a seqcount")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  drivers/net/vrf.c | 2 ++
>  1 file changed, 2 insertions(+)

Dave: drop this one. I'll resubmit a flags + features update after Eric 
resolves the lock issue.
