From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH 1/2] sctp: fix a typo in prototype of __sctp_rcv_lookup()
Date: Fri, 05 Oct 2012 09:37:17 +0200
Message-ID: <506E8E2D.3020904@6wind.com>
References: <1349279002-4008-1-git-send-email-nicolas.dichtel@6wind.com> <506DC190.6050407@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:48945 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300Ab2JEHhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 03:37:21 -0400
Received: by mail-wg0-f42.google.com with SMTP id fm10so140728wgb.1
        for <netdev@vger.kernel.org>; Fri, 05 Oct 2012 00:37:20 -0700 (PDT)
In-Reply-To: <506DC190.6050407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/10/2012 19:04, Vlad Yasevich a =E9crit :
> On 10/03/2012 11:43 AM, Nicolas Dichtel wrote:
>> Just to avoid confusion when people only reads this prototype.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>   net/sctp/input.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/sctp/input.c b/net/sctp/input.c
>> index 25dfe73..8bd3c27 100644
>> --- a/net/sctp/input.c
>> +++ b/net/sctp/input.c
>> @@ -68,8 +68,8 @@
>>   static int sctp_rcv_ootb(struct sk_buff *);
>>   static struct sctp_association *__sctp_rcv_lookup(struct net *net,
>>                         struct sk_buff *skb,
>> -                      const union sctp_addr *laddr,
>>                         const union sctp_addr *paddr,
>> +                      const union sctp_addr *laddr,
>>                         struct sctp_transport **transportp);
>>   static struct sctp_endpoint *__sctp_rcv_lookup_endpoint(struct net=
 *net,
>>                           const union sctp_addr *laddr);
>>
>
> Wow,  this must have been very old...

v2.5.33 ;-)
