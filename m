From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH v2 net] net: Always untag vlan-tagged traffic on input.
Date: Mon, 29 Sep 2014 15:58:15 +0200
Message-ID: <54296577.6050401@6wind.com>
References: <1407523333-31455-1-git-send-email-vyasevic@redhat.com> <54295449.7030203@6wind.com> <20140929130543.GB1839@nanopsycho.orion> <542962CF.6000602@6wind.com> <542964B2.3090303@redhat.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: vyasevic@redhat.com, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:46846 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751921AbaI2N6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 09:58:20 -0400
Received: by mail-we0-f171.google.com with SMTP id w61so327796wes.2
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 06:58:19 -0700 (PDT)
In-Reply-To: <542964B2.3090303@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 29/09/2014 15:54, Vlad Yasevich a =E9crit :
> On 09/29/2014 09:46 AM, Nicolas Dichtel wrote:
>> Le 29/09/2014 15:05, Jiri Pirko a =E9crit :
>>> Mon, Sep 29, 2014 at 02:44:57PM CEST, nicolas.dichtel@6wind.com wro=
te:
>>>> Le 08/08/2014 20:42, Vladislav Yasevich a =E9crit :
>>>> [snip]
>>>>>
>>>>> The patch attempt to fix this another way.  It moves the vlan hea=
der
>>>>> stipping code out of the vlan module and always builds it into th=
e
>>>>> kernel network core.  This way, even if vlan is not supported on
>>>>> a virtualizatoin host, the virtual machines running on top of suc=
h
>>>>> host will still work with VLANs enabled.
>>>> After this patch (0d5501c1c828 ("net: Always untag vlan-tagged tra=
ffic on
>>>> input.")), tcpdump will not be able to display the VLAN header on =
input path.
>>>> Is this really intended?
>>>
>>> I assume you are talking about the case when CONFIG_VLAN_8021Q is "=
n"
>>> right? Because if it is "m" of "y" I see no change in the code.
>> Right.
>>
>>>
>>> In case of CONFIG_VLAN_8021Q is "n" the only change is that for
>>> non-accelerated path, skb->vlan_tci is set and vlan header is strip=
ped.
>>> This makes the path same to accelerated path.
>>>
>>> tcpdump should be able to cope with skb->vlan_tci
>> My fault, I've tested with a quite old tcpdump version, with a recen=
t one it
>> works perfectly!
>
> Thanks.   BTW,  did that old tcpdump version work correctly when CONF=
IG_VLAN_8021Q
> was y or m?  My guess is that it would not.
Your guess is right ;-)


Nicolas
