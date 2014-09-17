From: Cong Wang <cwang@twopensource.com>
Subject: Re: Cannot move macvlan interface on top of bonding device
Date: Wed, 17 Sep 2014 13:25:23 -0700
Message-ID: <CAHA+R7Pmk-z2T=PQT3wzJPr2AVtQgeJ5Vcxhrd3Ey23sdHqtNw@mail.gmail.com>
References: <CA+HUmGi74nx0zELqXX63nJCNXshTC9AkWoRG5bo6AMHyr_3+fg@mail.gmail.com>
	<CAHA+R7O0LuvFujDnDjW-kcwG=9BGbaSBfO9GXhxD0ANLyeJLXQ@mail.gmail.com>
	<20140917190626.GA11354@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Francesco Ruggeri <fruggeri@arista.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Weilong Chen <chenweilong@huawei.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:50241 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756805AbaIQUZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 16:25:25 -0400
Received: by mail-la0-f50.google.com with SMTP id ty20so2619380lab.23
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 13:25:24 -0700 (PDT)
In-Reply-To: <20140917190626.GA11354@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 17, 2014 at 12:06 PM, Florian Westphal <fw@strlen.de> wrote:
> Cong Wang <cwang@twopensource.com> wrote:
>> On Wed, Sep 17, 2014 at 8:56 AM, Francesco Ruggeri <fruggeri@arista.com> wrote:
>> > This used to work in older releases.
>> > The problem seems to be that commit f939981492 sets NETIF_F_NETNS_LOCAL
>> > on bonding interfaces, and commit 797f87f83 causes macvlan interfaces
>> > to inherit its features from the lower device.
>> >
>> > Is there a reason why NETIF_F_NETNS_LOCAL should be inherited from the
>> > lower device
>> > by macvlan interfaces?
>>
>> commit 797f87f83 looks wrong, it should not inherit NETIF_F_NETNS_LOCAL,
>> so just clear this flag. Please submit a patch.
>
> Under which conditions would NETIF_F_NETNS_LOCAL have to be inherited?
> (i.e., why is it inheritable in the first place?)

Huh? Kidding me?
Isn't the question for yourself the author of commit 797f87f83?
