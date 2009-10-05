From: Ben Greear <greearb@candelatech.com>
Subject: Re: [net-next-2.6 PATCH 6/9] vxge: Check if FCS stripping is disabled
 by the firmware.
Date: Mon, 05 Oct 2009 09:44:11 -0700
Message-ID: <4ACA225B.6020809@candelatech.com>
References: <Pine.GSO.4.10.10910050755480.9377-100000@guinness> <4AC9EEE0.5000601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>,
	davem@davemloft.net, netdev@vger.kernel.org, support@neterion.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:45972 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753549AbZJEQpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 12:45:01 -0400
In-Reply-To: <4AC9EEE0.5000601@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2009 06:04 AM, Eric Dumazet wrote:
> Sreenivasa Honnur a =E9crit :
>> - Added a function to check if FCS stripping is disabled by the firm=
ware, if
>>    it is not disabled fail driver load.
>>
>> - By default FCS stripping is disabled by the firmware. With this as=
sumption
>>    driver decrements the indicated packet length by 4 bytes(FCS leng=
th).
>>
>> - This patch ensures that FCS stripping is disabled during driver lo=
ad time.
>>
>> Signed-off-by: Sreenivasa Honnur<sreenivasa.honnur@neterion.com>
>
> What the big deal about FCS not being stripped ?

I'd consider it a feature to be able to receive the CRC...would be nice=
 for
sniffing applications!

Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

