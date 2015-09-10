From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH 2/2 v2] net: Remove VRF change to udp_sendmsg
Date: Wed, 9 Sep 2015 21:32:30 -0600
Message-ID: <55F0F9CE.30307@cumulusnetworks.com>
References: <CALx6S35scg=6vr9zPBD=_VPHGDwkq22hQM4Ce2roi4j5DXrYZw@mail.gmail.com>
 <55F0CD92.7080700@cumulusnetworks.com>
 <CALx6S35Fwu5QsR-W=0LVzvZv_PGqbV3TGR9T5YRU65QCY0OgzQ@mail.gmail.com>
 <20150909.202026.215174674574675091.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:36816 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821AbbIJDcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 23:32:32 -0400
Received: by ioii196 with SMTP id i196so46079697ioi.3
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 20:32:32 -0700 (PDT)
In-Reply-To: <20150909.202026.215174674574675091.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/9/15 9:20 PM, David Miller wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Wed, 9 Sep 2015 17:51:19 -0700
>
>> Consider that ip_local_out_sk calls netfilter NF_INET_LOCAL_OUT hook
>> before dst->output, so then netfilter would start seeing packets
>> with zero source address???
>
> I have to agree with Tom here, this is fatal.
>

Ok. I will drop this topic for 4.3; revisit for 4.4.

David
