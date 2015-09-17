From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: list of all network namespaces
Date: Thu, 17 Sep 2015 11:46:27 +0200
Message-ID: <55FA8BF3.2090405@6wind.com>
References: <CAOxq_8Noj5oxPY5BEsWL6u4h_AD+oXYS+JCRGES_gmMQKd0rOQ@mail.gmail.com>
 <55FA0F4A.3010105@hp.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Rick Jones <rick.jones2@hp.com>, Ani Sinha <ani@arista.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38496 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001AbbIQJqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 05:46:31 -0400
Received: by wiclk2 with SMTP id lk2so19701161wic.1
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 02:46:30 -0700 (PDT)
In-Reply-To: <55FA0F4A.3010105@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/09/2015 02:54, Rick Jones a =C3=A9crit :
> On 09/16/2015 05:46 PM, Ani Sinha wrote:
>> Hi guys
>>
>> just a stupid question. Is it possible to get a list of all active
>> network namespaces in the kernel through /proc or some other
>> interface?
>
> Presumably you could copy what "ip netns" does, which appears to be t=
o look in
> /var/run/netns .  At least that is what an strace of that command sug=
gests.
This will only list netns referenced in '/var/run/netns', which is not =
'all'
existing netns (most probably only netns created by iproute2).

Regards,
Nicolas
