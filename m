From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 01/13] openvswitch: split flow structures into
 ovs specific and generic ones
Date: Wed, 03 Sep 2014 17:11:56 -0400
Message-ID: <5407841C.3040301@mojatatu.com>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us> <1409736300-12303-2-git-send-email-jiri@resnulli.us> <540731B9.4010603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:63857 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756340AbaICVMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 17:12:00 -0400
Received: by mail-ig0-f174.google.com with SMTP id a13so1606345igq.7
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 14:12:00 -0700 (PDT)
In-Reply-To: <540731B9.4010603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/14 11:20, John Fastabend wrote:

> Also I have some filters that can match on offset/length/mask
> tuples. As far as I can tell this is going to have to be yet
> another interface? Or would it be worth the effort to define
> the flow key more generically. My initial guess is I'll just
> write a separate interface. I think this is what Jamal referred
> to as another "classifier".
>

Exactly. I have more complex classifiers as stated earlier.
I am afraid these patches again are not satisfying that need.

In any case - we are taking a different tact than these patches
do and hopefully at some point we can merge thoughts.

cheers,
jamal
