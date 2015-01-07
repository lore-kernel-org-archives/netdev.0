From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 01/11] net: flow_table: create interface for
 hw match/action tables
Date: Wed, 07 Jan 2015 08:35:37 -0800
Message-ID: <54AD6059.9030901@gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32> <20141231194544.31070.30335.stgit@nitbit.x32> <20150104111238.GD15305@casper.infradead.org> <54AADEFF.3090306@gmail.com> <CAJ3xEMiMsHW9Wys2GMhD9CRhU03DF3KZywGQkTWF1sMKn8x+fQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	simon.horman@netronome.com,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:62568 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752713AbbAGQfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 11:35:53 -0500
Received: by mail-ob0-f178.google.com with SMTP id gq1so3894842obb.9
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 08:35:53 -0800 (PST)
In-Reply-To: <CAJ3xEMiMsHW9Wys2GMhD9CRhU03DF3KZywGQkTWF1sMKn8x+fQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2015 02:07 AM, Or Gerlitz wrote:
> On Mon, Jan 5, 2015 at 8:59 PM, John Fastabend <john.fastabend@gmail.com> wrote:
>>>> +struct sk_buff *net_flow_build_actions_msg(struct net_flow_action **a,
>>>> +                                          struct net_device *dev,
>>>> +                                          u32 portid, int seq, u8 cmd)
>>>> +{
>>>> +       struct genlmsghdr *hdr;
>>>> +       struct sk_buff *skb;
>>>> +       int err = -ENOBUFS;
>>>> +
>>>> +       skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
>>>
>>>
>>> genlmsg_new(GENLMSG_DEFAULT_SIZE, GFP_KERNEL);
>>
>>
>> fixed along with the other cases.
>
> small nit here, net_flow_build_actions_msg can be made static, it's
> called only from within this file
>
> few more nits... checkpatch --strict produces bunch of "CHECK: Please
> use a blank line after function/struct/union/enum declarations"
> comments, I guess worth fixing too.
>

Thanks. will fix in v2.

-- 
John Fastabend         Intel Corporation
