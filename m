From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] loopback: explicitly set pkt_type to PACKET_HOST
Date: Fri, 16 May 2014 13:57:58 -0700
Message-ID: <CAM_iQpXrvXUGq_ZPx0n0H9251_4hXVb_jpeUVDdBEtJ6beSNJw@mail.gmail.com>
References: <1400092762-23287-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140515.163400.1536463708975272927.davem@davemloft.net>
	<CAM_iQpVGG92NMYTJuCXg3yhCkVDyL3Tf=5HJy6n2V1Z89yySzw@mail.gmail.com>
	<20140516.151701.1642109390027874890.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:58749 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002AbaEPU56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 16:57:58 -0400
Received: by mail-oa0-f42.google.com with SMTP id j17so3645269oag.15
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 13:57:58 -0700 (PDT)
In-Reply-To: <20140516.151701.1642109390027874890.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2014 at 12:17 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
>> Oh, I meant using tc mirred action to redirect packets from vethX to lo.
>> Sorry for confusing.
>
> I think you can't expect arbitrary redirection of packets from an outgoing
> interface back into the stack via loopback to work like that.
>
> The is never any legitimate reason in this type of flow to override the
> decisions made by eth_type_trans() as to the disposition of the packet type.
>

Yeah, it's ok, probably setting the right mac on vethX is the real fix
to this problem in my case.

Thanks.
