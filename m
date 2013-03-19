From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH v2 net-next 1/5] GRE: Refactor GRE tunneling code.
Date: Mon, 18 Mar 2013 20:11:32 -0700
Message-ID: <CALnjE+q+EmB8V_dWVWY1DdjsdT3U13_kWekW820n1oB+qx-_=Q@mail.gmail.com>
References: <1363630405-1672-1-git-send-email-pshelar@nicira.com>
	<20130318122409.00c01106@nehalam.linuxnetplumber.net>
	<20130318.153319.206719819832403477.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:36166 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752859Ab3CSDLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 23:11:34 -0400
Received: by mail-ob0-f198.google.com with SMTP id dn14so74726obc.5
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 20:11:32 -0700 (PDT)
In-Reply-To: <20130318.153319.206719819832403477.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 18, 2013 at 12:33 PM, David Miller <davem@davemloft.net> wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Mon, 18 Mar 2013 12:24:09 -0700
>
>> On Mon, 18 Mar 2013 11:13:25 -0700
>> Pravin B Shelar <pshelar@nicira.com> wrote:
>>
>>> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
>>> index 7944df7..2073226 100644
>>> --- a/net/ipv4/Kconfig
>>> +++ b/net/ipv4/Kconfig
>>> @@ -186,9 +186,14 @@ config NET_IPGRE_DEMUX
>>>       This is helper module to demultiplex GRE packets on GRE version field criteria.
>>>       Required by ip_gre and pptp modules.
>>>
>>> +config NET_IP_TUNNEL
>>> +    tristate
>>> +    default n
>>> +
>>
>> Won't this break existing kernel config's, shouldn't this default y?
>
> Or "m".  But indeed, it should be made to automatically work for
> existing configs.

ok,
I will post updated patch.

Thanks.
