From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 0/4] udp: UDP tunnel enhancements
Date: Mon, 14 Jul 2014 16:23:43 -0700
Message-ID: <CA+mtBx_sBxbY7r6_mDDo0pE5Nakg3CwL71bawBMtW0fzfU1Uww@mail.gmail.com>
References: <alpine.DEB.2.02.1407131942580.25072@tomh.mtv.corp.google.com>
	<20140714.161254.1495587038499399882.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:54653 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694AbaGNXXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 19:23:44 -0400
Received: by mail-ie0-f175.google.com with SMTP id x19so3946405ier.34
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 16:23:43 -0700 (PDT)
In-Reply-To: <20140714.161254.1495587038499399882.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2014 at 4:12 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Sun, 13 Jul 2014 19:49:29 -0700 (PDT)
>
>> - Add udp_sock_create in new helper module udp_tunnel. Tunnel
>>   implementations call this function to create listener UDP ports.
>> - Make vxlan and l2tp call udp_sock_create.
>> - Move udp_tunnel_segment into udp_offload.c.
>
> Series applied, thank Tom.
>
> Please make the target tree (net-next in this case) explicit in
> future submissions.
>
Thanks. Should all patch submissions to netdev either be targeted to
net or net-next then?

> Thanks again.
