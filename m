From: Johan Andersson <johan.andersson@transmode.se>
Subject: Re: e1000e: Hardware CRC stripping doesn't work with 82566DM-2
Date: Thu, 07 Feb 2008 07:19:16 +0100
Message-ID: <47AAA2E4.5010007@transmode.se>
References: <47AA1BB4.8010802@transmode.se> <47AA2A03.2000109@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:63895 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759421AbYBGGT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 01:19:27 -0500
In-Reply-To: <47AA2A03.2000109@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kok, Auke wrote:
> Johan Andersson wrote:
>   
>> Hi,
>>
>> In commit 140a74802894e9db57e5cd77ccff77e590ece5f3 a workaround for crc
>> stripping was removed.
>> However, the hardware supported crc stripping now in use doesn't seem to
>> work with the following chip:
>> Intel Corporation 82566DM-2 Gigabit Network Connection (rev 02) (8086:10bd)
>>
>> I discovered this while trying to make this nic member of a bridge.
>> Since some frames get too large for the bridge they are dropped, making
>> it impossible to use this nic in a bridge.
>>
>> Reverting this commit makes the nic and brigde work again.
>>
>> Are there any more chips in this family suffering from this?
>>     
>
> I have only heard from this issue for 82566dm-2 chipsets, but I'm looking into it
> atm (time permitting). It has been reported by Herbert Xu to cause issues in the
> same matter last week.
>
> I'm not sure what the real issue is right now, I hope to get an answer on this later.
>
> Auke
>
>   
Ok, thanks. Tell me if I can help out in any way.

/Johan
