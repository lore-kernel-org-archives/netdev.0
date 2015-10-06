From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCHv3 net 2/6] openvswitch: Fix skb leak in ovs_fragment()
Date: Tue, 6 Oct 2015 11:01:06 -0700
Message-ID: <CANr6G5zbAG5z4ReW50X48r7Lry3HnJ=AtRV4Y_yiZobQ1jm69w@mail.gmail.com>
References: <1444083799-57090-1-git-send-email-joestringer@nicira.com>
 <1444083799-57090-3-git-send-email-joestringer@nicira.com> <5613D6B8.2080006@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Pravin Shelar <pshelar@nicira.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:33108 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456AbbJFSB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 14:01:26 -0400
Received: by ykft14 with SMTP id t14so211396865ykf.0
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 11:01:25 -0700 (PDT)
In-Reply-To: <5613D6B8.2080006@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6 October 2015 at 07:12, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 10/6/2015 1:23 AM, Joe Stringer wrote:
>
>> If ovs_fragment() was unable to fragment the skb due to an L2 header
>> that exceeds the supported length, skbs would be leaked. Fix the bug.
>>
>> Fixes: 7f8a436 "openvswitch: Add conntrack action"
>
>
>    12-digit SHA1 needed here. And parens along with double quotes as well.

OK, I sent a fresh series with all of the SHA1s updated.
