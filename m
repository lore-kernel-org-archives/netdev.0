From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH next 3/3] net: Use l3_dev instead of skb->dev for L3 processing
Date: Wed, 9 Mar 2016 16:09:39 -0800
Message-ID: <CAM_iQpUv-YrbXTQvWe8Npj0XaaaE7HM_j-=su7TJV9HF8c1kuw@mail.gmail.com>
References: <1456783704-18746-1-git-send-email-mahesh@bandewar.net>
	<CAM_iQpXmoSZhNw+CCbFw5b6Dzq4W+vt5WH8FmRc1ZiuJgv1xnQ@mail.gmail.com>
	<CAF2d9jhopDVGxsSM3wfYh2XgENebJNbEOn9D7Vb8t13bQ7dRcQ@mail.gmail.com>
	<CAF2d9jiyjThgeQKw==tKRk3Sh0dNfzUdwJciwsVGPFLdb9uGTA@mail.gmail.com>
	<CAM_iQpUB_b3S_Mi8QyzhX_XBog3+ZshY8xbSby5eUytnG2OQRg@mail.gmail.com>
	<CAF2d9jhgoWeZdPkM-aev6j9a8OjUQ78CbE7dgp1wPXu91qp_-A@mail.gmail.com>
	<CAM_iQpVoRuWgk6_x-MWj=A520XjpC3e2QoPspQG6pfd--+m=KA@mail.gmail.com>
	<CAF2d9jg2ioCsRa+FHUnwEYSXmqszd6h8MFOcWpWaT4ikaUKc0w@mail.gmail.com>
	<CAM_iQpXHHMvbOMO5iG8jhk5yz3CyxB0641FYhcRPA65HL7DLjA@mail.gmail.com>
	<CAF2d9jh7fbGgibzTgRfNppgVi2tm9j8p6OJHxiaR0ZmGzLe4dg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>, Tim Hockin <thockin@google.com>,
	Alex Pollitt <alex.pollitt@metaswitch.com>,
	Matthew Dupre <matthew.dupre@metaswitch.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f178.google.com ([209.85.161.178]:35669 "EHLO
	mail-yw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934123AbcCJAJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 19:09:40 -0500
Received: by mail-yw0-f178.google.com with SMTP id g127so54373119ywf.2
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 16:09:39 -0800 (PST)
In-Reply-To: <CAF2d9jh7fbGgibzTgRfNppgVi2tm9j8p6OJHxiaR0ZmGzLe4dg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 8, 2016 at 10:42 AM, Mahesh Bandewar <maheshb@google.com> wrote:
>> The more subsystems involves, the more struct net pointers you
>> potentially need to touch, the less likely you can make it correct
>> by just switching skb->dev.
>
> Please drop that prejudice and read the patch-set carefully. I'm
> neither changing
> any *net* pointers nor changing the skb->dev pointers anywhere. All I'm saying
> is dev->l3_dev is what we'll use for *all* L3 processing and no need to change
> skb->dev or net-ns of any device(s) involved.

Please don't misinterpret me.

I said _switching_, not overwriting or changing, you use dev->l3_dev to _switch_
skb->dev and/or net, this is exactly what I am complaining about. This is not
how netns works.
