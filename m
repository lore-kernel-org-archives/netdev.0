From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH v2] XFRM: remove redundant parameter "int dir" in struct
 xfrm_mgr.acquire
Date: Thu, 16 Aug 2012 09:12:13 +0800
Message-ID: <502C48ED.7040509@windriver.com>
References: <1344996827-20620-1-git-send-email-fan.du@windriver.com> <20120815.151403.2191772611303249590.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:35846 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755974Ab2HPBLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2012 21:11:48 -0400
In-Reply-To: <20120815.151403.2191772611303249590.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012=E5=B9=B408=E6=9C=8816=E6=97=A5 06:14, David Miller wrote:
> From: Fan Du<fan.du@windriver.com>
> Date: Wed, 15 Aug 2012 10:13:47 +0800
>
>> Sematically speaking, xfrm_mgr.acquire is called when kernel intends=
 to ask
>> user space IKE daemon to negotiate SAs with peers. IOW the direction=
 will
>> *always* be XFRM_POLICY_OUT, so remove int dir for clarity.
>>
>> Signed-off-by: Fan Du<fan.du@windriver.com>
>> ---
>> Changelog for V2:
>> 	- Remove "int dir" in build_acquire parameter suggested by Steffen =
Klassert.
>
> Applied, thanks.
>
> Please use lowercase "xfrm: " for subsystem indications in your subje=
ct
> lines, I fixed it up this time.
>
> Thanks again.

Well understood, will do it next time :)

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--=20

Love each day!
--fan
