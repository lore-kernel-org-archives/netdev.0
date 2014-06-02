From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 2/2] bridge netlink dump interface at par with
 brctl Actually better than brctl showmacs because we can filter by bridge
 port in the kernel
Date: Mon, 02 Jun 2014 18:17:50 -0400
Message-ID: <538CF80E.5010009@mojatatu.com>
References: <1401623780-4297-1-git-send-email-jhs@emojatatu.com> <1401623780-4297-2-git-send-email-jhs@emojatatu.com> <538C9988.3040902@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@cumulusnetworks.com,
	john.r.fastabend@intel.com, roopa@cumulusnetworks.com
To: vyasevic@redhat.com, davem@davemloft.net,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:42928 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128AbaFBWSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 18:18:00 -0400
Received: by mail-ig0-f178.google.com with SMTP id hl10so4020504igb.17
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 15:17:59 -0700 (PDT)
In-Reply-To: <538C9988.3040902@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/14 11:34, Vlad Yasevich wrote:

>
> I think that after this code, if you set a bridge mac address thus
> causing an fdb like:
>    <mac> dev br0 vlan 0 master permanent  (old notation)
>
> you will not show it if you set the br_idx with
>    # bridge fdb show br br0
>
>
> I looks like the only way to show such fdb is not set any filters at all
> since if you set a port filter, you will not see it either as it will be
> filtered out in bridge code.
>

I thought the comment which says "selfie" would take care of that; i.e
the default dump would do it.
If you give me an example of setting such an entry I will try it out
and see if it works.

cheers,
jamal
