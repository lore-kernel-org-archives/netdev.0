From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/9] be2net: replace (1 << x) with BIT(x)
Date: Mon, 16 Feb 2015 16:13:10 +0300
Message-ID: <54E1ECE6.60703@cogentembedded.com>
References: <1423228723-10919-1-git-send-email-sathya.perla@emulex.com> <1423228723-10919-3-git-send-email-sathya.perla@emulex.com> <54E1DDF4.5040901@cogentembedded.com> <CF9D1877D81D214CB0CA0669EFAE020C74C34365@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Sathya Perla <Sathya.Perla@Emulex.Com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:53688 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755813AbbBPNNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 08:13:13 -0500
Received: by mail-lb0-f176.google.com with SMTP id u10so27062515lbd.7
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2015 05:13:12 -0800 (PST)
In-Reply-To: <CF9D1877D81D214CB0CA0669EFAE020C74C34365@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/16/2015 3:55 PM, Sathya Perla wrote:

>>> From: Vasundhara Volam <vasundhara.volam@emulex.com>

>>> BIT(x) is the preffered usage.

>>      Preferred.

> :-) As this is a harmless spelling mistake only in the changelog,
> I'll not bother sending a new patch for this!

    OK...

>> [...]

>>> diff --git a/drivers/net/ethernet/emulex/benet/be.h
>> b/drivers/net/ethernet/emulex/benet/be.h
>>> index 3b1d59d..9869556 100644
>>> --- a/drivers/net/ethernet/emulex/benet/be.h
>>> +++ b/drivers/net/ethernet/emulex/benet/be.h
>>> @@ -361,15 +361,15 @@ enum vf_state {
>>>    	ASSIGNED = 1
>>>    };
>>>
>>> -#define BE_FLAGS_LINK_STATUS_INIT		1
>>> -#define BE_FLAGS_SRIOV_ENABLED			(1 << 2)
>>> -#define BE_FLAGS_WORKER_SCHEDULED		(1 << 3)
>>> -#define BE_FLAGS_VLAN_PROMISC			(1 << 4)
>>> -#define BE_FLAGS_MCAST_PROMISC			(1 << 5)
>>> -#define BE_FLAGS_NAPI_ENABLED			(1 << 9)
>>> -#define BE_FLAGS_QNQ_ASYNC_EVT_RCVD		(1 << 11)
>>> -#define BE_FLAGS_VXLAN_OFFLOADS			(1 << 12)
>>> -#define BE_FLAGS_SETUP_DONE			(1 << 13)
>>> +#define BE_FLAGS_LINK_STATUS_INIT		BIT(1)

>>      Not BIT(0)?

> Huh, this was not intentional. I'll remember to use bit-0 the next time
> we introduce a new bit!

    Note that bit 0 was used for BE_FLAGS_LINK_STATUS_INIT before your patch.

[...]

WBR, Sergei
