From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH 19/29] net: vrf: Add vrf context to skb
Date: Thu, 05 Feb 2015 23:00:29 -0700
Message-ID: <54D4587D.5090408@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>	<1423100070-31848-20-git-send-email-dsahern@gmail.com> <878ugbwv7t.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:51542 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754560AbbBFGAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 01:00:36 -0500
Received: by mail-ig0-f173.google.com with SMTP id a13so5923144igq.0
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 22:00:35 -0800 (PST)
In-Reply-To: <878ugbwv7t.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/5/15 8:54 PM, Eric W. Biederman wrote:
> David Ahern<dsahern@gmail.com>  writes:
>
>> >On ingress skb's inherit vrf context from the net_device. For TX skb's
>> >inherit the vrf context from the socket originating the packet. Update
>> >SKB related net_ctx macros to set vrf.
> Nacked-by: "Eric W. Biederman"<ebiederm@xmission.com>
>
> As I recall we had the conversation about modifying  struct sk_buff when
> implementing network namespaces and it turns out it is a no go.  It adds
> too much overhead.  As I recall skbs as they are on the fastpath are
> things we want to make smaller.
>

Ok, I will look into removing the need for this change.

David
