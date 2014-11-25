From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next v3 02/17] net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del
Date: Tue, 25 Nov 2014 07:43:13 -0800
Message-ID: <5474A391.2080204@gmail.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-3-git-send-email-jiri@resnulli.us> <20141125151312.GC27416@gospo.rtplab.test> <20141125151811.GF1971@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gm
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:57440 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbaKYPnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 10:43:55 -0500
Received: by mail-oi0-f52.google.com with SMTP id h136so567596oig.39
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 07:43:55 -0800 (PST)
In-Reply-To: <20141125151811.GF1971@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/2014 07:18 AM, Jiri Pirko wrote:
> Tue, Nov 25, 2014 at 04:13:12PM CET, gospo@cumulusnetworks.com wrote:
>> On Tue, Nov 25, 2014 at 11:28:33AM +0100, Jiri Pirko wrote:
>>> Do the work of parsing NDA_VLAN directly in rtnetlink code, pass simple
>>> u16 vid to drivers from there.
>>>
>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>
>> Structurally this looks fine, just a misspelling noted below.
>>
>> Acked-by: Andy Gospodarek <gospo@cumulusnetworks.com>
>>

If your going to spin this, should we return an error from
ndo_dflt_fdb_add() when we have a non-zero vid? The dflt
handler uses the dev_(mc|uc)_add_excl routines which will
not consume vids.

If you want to address this with a follow up patch I'm OK
with that. Go ahead and add my ack,

Acked-by: John Fastabend <john.r.fastabend@intel.com>


-- 
John Fastabend         Intel Corporation
