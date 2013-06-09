From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH RFC 1/2] net/core: Add netlink directives to control VF
 link state
Date: Sun, 9 Jun 2013 12:51:15 +0300
Message-ID: <51B45013.5000708@mellanox.com>
References: <1368020717-22194-1-git-send-email-ogerlitz@mellanox.com> <1368020717-22194-2-git-send-email-ogerlitz@mellanox.com> <518A76FB.5030704@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <amirv@mellanox.com>,
	<ronye@mellanox.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:39258 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753359Ab3FIJvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jun 2013 05:51:19 -0400
In-Reply-To: <518A76FB.5030704@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/05/2013 19:02, Sergei Shtylyov wrote:
>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>> index a08bd2b..bec44a3 100644
>> --- a/net/core/rtnetlink.c
>> +++ b/net/core/rtnetlink.c
>> @@ -1238,6 +1238,15 @@ static int do_setvfinfo(struct net_device 
>> *dev, struct nlattr *attr)
>>                                      ivs->setting);
>>               break;
>>           }
>> +        case IFLA_VF_LINK_STATE: {
>> +            struct ifla_vf_link_state *ivl;
>> +            ivl = nla_data(vf);
>
>     Why not make it initializer? And empty line is needed between the 
> declaration and other code. 

b/c we followed the conventions introduced in the preceding cases of 
do_setvfinfo which we found to be OK
