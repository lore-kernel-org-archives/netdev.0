From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH 02/29] net: Flip net_device to use net_ctx
Date: Thu, 05 Feb 2015 17:45:03 -0700
Message-ID: <54D40E8F.9050006@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com> <1423100070-31848-3-git-send-email-dsahern@gmail.com> <54D37468.6040508@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com
To: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:43307 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbbBFApK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 19:45:10 -0500
Received: by mail-ig0-f169.google.com with SMTP id hl2so9646696igb.0
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 16:45:09 -0800 (PST)
In-Reply-To: <54D37468.6040508@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/5/15 6:47 AM, Nicolas Dichtel wrote:
> Le 05/02/2015 02:34, David Ahern a =C3=A9crit :
>> +static inline
>> +int dev_net_ctx_eq(const struct net_device *dev, struct net_ctx *ct=
x)
>> +{
>> +    if (net_eq(dev_net(dev), ctx->net))
>> +        return 1;
> Why not using net_ctx_eq()?

right, will change it.
