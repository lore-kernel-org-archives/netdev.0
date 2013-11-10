From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] nfnetlink: do not ack malformed messages
Date: Sun, 10 Nov 2013 01:46:56 +0000 (UTC)
Message-ID: <slrnl7tpcq.5er.xiyou.wangcong@linux-6brj.site>
References: <fa44451df8aa56773b1b17cbbd86ced8b54eca5a.1383850681.git.jbenc@redhat.com>
 <527C1C38.40908@cogentembedded.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:52402 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758576Ab3KJBrS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Nov 2013 20:47:18 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VfK7R-0000SY-3z
	for netdev@vger.kernel.org; Sun, 10 Nov 2013 02:47:17 +0100
Received: from c-24-5-209-215.hsd1.ca.comcast.net ([24.5.209.215])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 10 Nov 2013 02:47:17 +0100
Received: from xiyou.wangcong by c-24-5-209-215.hsd1.ca.comcast.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 10 Nov 2013 02:47:17 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 07 Nov 2013 at 23:03 GMT, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:
>> --- a/net/netfilter/nfnetlink.c
>> +++ b/net/netfilter/nfnetlink.c
>> @@ -363,13 +363,15 @@ static void nfnetlink_rcv(struct sk_buff *skb)
>>   	struct net *net = sock_net(skb->sk);
>>   	int msglen;
>>
>> -	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
>> -		return netlink_ack(skb, nlh, -EPERM);
>> -
>
>     Hm, how it even compiled before your patch?
>

You can return void inside a void function.
