From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next v2 0/9] introduce rocker switch driver with hardware
 accelerated datapath api
Date: Fri, 19 Sep 2014 22:37:35 -0700
Message-ID: <541D129F.8040706@gmail.com>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us> <063D6719AE5E284EB5DD2968C1650D6D17495CC6@AcuExch.aculab.com> <20140919142032.GF1980@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"sfeldma@cumulusnetworks.com" <sfe
To: Jiri Pirko <jiri@resnulli.us>,
	David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:47773 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752685AbaITFhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 01:37:41 -0400
Received: by mail-oa0-f53.google.com with SMTP id eb12so2393462oac.26
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 22:37:41 -0700 (PDT)
In-Reply-To: <20140919142032.GF1980@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/14 07:20, Jiri Pirko wrote:
> Fri, Sep 19, 2014 at 04:15:32PM CEST, David.Laight@ACULAB.COM wrote:
>> From: Jiri Pirko
>>> This patchset can be divided into 3 main sections:
>>> - introduce switchdev api for implementing switch drivers
>>> - introduce switchdev generic netlink api for userspace manipulation
>>> - introduce rocker switch driver which implements switchdev api
>>
>> Perhaps you should be including the name of what you are switching
>> in the name of the API?
>>
>> Is this for interfacing to ethernet switches, TDM switches or
>> mechanical ones?
>> It isn't really clear from any of these commit messages.
>
> I thought that is isn't necessary, that it is clear this is about ethernet
> switches.
>

How about putting some of this code in net/ethernet/* to make very very 
obvious this is what this thing is about?
--
Florian
