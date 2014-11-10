From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 01/10] net: rename netdev_phys_port_id to
 more generic name
Date: Mon, 10 Nov 2014 07:06:29 -0500
Message-ID: <5460AA45.6000007@mojatatu.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>	<1415530280-9190-2-git-send-email-jiri@resnulli.us>	<54603270.509@mojatatu.com> <20141110.002336.70350092543746386.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:58890 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbaKJMGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 07:06:34 -0500
Received: by mail-ie0-f171.google.com with SMTP id x19so9110374ier.30
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 04:06:34 -0800 (PST)
In-Reply-To: <20141110.002336.70350092543746386.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/14 00:23, David Miller wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> Date: Sun, 09 Nov 2014 22:35:12 -0500
>
>> wouldnt this just break an existing ABI? You may need to introduce a
>> new attribute.
>
> He isn't breaking anything Jamal, he's just changing the internal
> macro name we use for the attribute's maximum length.


It is a _user space visible rename_, how about:

#define MAX_PHYS_ITEM_ID_LEN 32
#define MAX_PHYS_PORT_ID_LEN   MAX_PHYS_ITEM_ID_LEN

I did miss the fact that the size didnt change.

cheers,
jamal
