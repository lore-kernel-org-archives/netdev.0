From: Sridhar Samudrala <samudrala.sridhar@gmail.com>
Subject: Re: [PATCH net-next] vxlan: don't bypass encapsulation for multi-
 and broadcasts
Date: Mon, 15 Apr 2013 10:39:25 -0700
Message-ID: <516C3B4D.9020906@gmail.com>
References: <1365931311-26285-1-git-send-email-mike.rapoport@ravellosystems.com> <kkhbiq$5bu$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "davem@davemloft.net" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f42.google.com ([209.85.128.42]:42047 "EHLO
	mail-qe0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932679Ab3DORj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 13:39:29 -0400
Received: by mail-qe0-f42.google.com with SMTP id cz11so2877434qeb.29
        for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 10:39:27 -0700 (PDT)
In-Reply-To: <kkhbiq$5bu$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/15/2013 9:58 AM, Cong Wang wrote:
> On Sun, 14 Apr 2013 at 09:21 GMT, Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
>> The multicast and broadcast packets may have RTCF_LOCAL set in rt_flags
>> and therefore will be sent out bypassing encapsulation. This breaks
>> delivery of packets sent to the vxlan multicast group.
>> Disabling encapsulation bypass for multicasts and broadcasts fixes the
>> issue.
>>
>> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
> This fixes the regression I reported.
>
> Tested-by: Cong Wang <xiyou.wangcong@gmail.com>
>
>
Acked-by: Sridhar Samudrala <sri@us.ibm.com>
Tested-by: Sridhar Samudrala <sri@us.ibm.com>

Thanks
Sridhar
