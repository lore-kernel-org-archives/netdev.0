From: Francesco Ruggeri <fruggeri@arista.com>
Subject: Re: Cannot move macvlan interface on top of bonding device
Date: Wed, 17 Sep 2014 13:49:45 -0700
Message-ID: <CA+HUmGiktVzNh7d1mRTf5Z30PO+sEvCr=T8RLfzsgUXrGf+bDw@mail.gmail.com>
References: <CA+HUmGi74nx0zELqXX63nJCNXshTC9AkWoRG5bo6AMHyr_3+fg@mail.gmail.com>
	<CAHA+R7O0LuvFujDnDjW-kcwG=9BGbaSBfO9GXhxD0ANLyeJLXQ@mail.gmail.com>
	<20140917190626.GA11354@breakpoint.cc>
	<5419F17D.2090409@gmail.com>
	<CAHA+R7M5+1gbfx7pv=bPdNempL1eeXRu-J79c29z1k6Mr-aXfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Weilong Chen <chenweilong@huawei.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:36459 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756625AbaIQUtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 16:49:46 -0400
Received: by mail-ob0-f176.google.com with SMTP id uz6so182496obc.7
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 13:49:46 -0700 (PDT)
In-Reply-To: <CAHA+R7M5+1gbfx7pv=bPdNempL1eeXRu-J79c29z1k6Mr-aXfA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>> May be a better solution is:
>>
>>         features = netdev_increment_features(vlan->lowerdev->features & MACVLAN_FEATURS,
>>                                              features,
>>                                              mask);
>>
>> This way we start with only the feature MACVLAN is interested in.
>>
>
> Or clear it in mask?

Do you guys see a problem with the patch I submitted (net: allow
macvlans to move to net namespace)?

Francesco
