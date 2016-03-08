From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH next 3/3] net: Use l3_dev instead of skb->dev for L3
 processing
Date: Tue, 8 Mar 2016 10:46:47 +0100
Message-ID: <56DE9F87.8060009@6wind.com>
References: <1456783704-18746-1-git-send-email-mahesh@bandewar.net>
 <CAM_iQpXmoSZhNw+CCbFw5b6Dzq4W+vt5WH8FmRc1ZiuJgv1xnQ@mail.gmail.com>
 <CAF2d9jhopDVGxsSM3wfYh2XgENebJNbEOn9D7Vb8t13bQ7dRcQ@mail.gmail.com>
 <CAF2d9jiyjThgeQKw==tKRk3Sh0dNfzUdwJciwsVGPFLdb9uGTA@mail.gmail.com>
 <CAM_iQpUB_b3S_Mi8QyzhX_XBog3+ZshY8xbSby5eUytnG2OQRg@mail.gmail.com>
 <CAF2d9jhgoWeZdPkM-aev6j9a8OjUQ78CbE7dgp1wPXu91qp_-A@mail.gmail.com>
 <CAM_iQpVoRuWgk6_x-MWj=A520XjpC3e2QoPspQG6pfd--+m=KA@mail.gmail.com>
 <CAF2d9jg2ioCsRa+FHUnwEYSXmqszd6h8MFOcWpWaT4ikaUKc0w@mail.gmail.com>
 <CAM_iQpXHHMvbOMO5iG8jhk5yz3CyxB0641FYhcRPA65HL7DLjA@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>, Tim Hockin <thockin@google.com>,
	Alex Pollitt <alex.pollitt@metaswitch.com>,
	Matthew Dupre <matthew.dupre@metaswitch.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37162 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084AbcCHJqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 04:46:51 -0500
Received: by mail-wm0-f47.google.com with SMTP id p65so19746925wmp.0
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 01:46:50 -0800 (PST)
In-Reply-To: <CAM_iQpXHHMvbOMO5iG8jhk5yz3CyxB0641FYhcRPA65HL7DLjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+ Eric B.

Le 08/03/2016 06:37, Cong Wang a =C3=A9crit :
> On Fri, Mar 4, 2016 at 2:12 PM, Mahesh Bandewar <maheshb@google.com> =
wrote:
>>
>> Unfortunately we don't have a way to switch to ns after L3 processin=
g.
>
> I am totally aware of this, this is exactly why I said this might not=
 be easy.
>
> The question is how hard it is to implement one? My gut feeling is we=
 only
> need to change some data in skb, something similar to skb_scrub_packe=
t().
> But I never even try.

Note that Eric Biederman has made "some" patches to be able to "control=
" the
netns on the egress side. The goal is to be able to have routes that le=
ak to
another netns.
It seems that the same work should probably be done at the ingress side=
=2E

I agree with Cong that just changing skb->dev is not the right approach=
=2E
