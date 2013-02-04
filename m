From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2] iplink: display the value of IFLA_PROMISCUITY
Date: Mon, 04 Feb 2013 18:27:51 +0100
Message-ID: <510FEF97.7040903@6wind.com>
References: <CB4696DA7737D0409230B481D0363B1414F0E60461@HQ1-EXCH03.corp.brocade.com> <20130204090419.2e351ac5@nehalam.linuxnetplumber.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:61825 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753654Ab3BDR14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 12:27:56 -0500
Received: by mail-wi0-f181.google.com with SMTP id hm6so1946471wib.14
        for <netdev@vger.kernel.org>; Mon, 04 Feb 2013 09:27:55 -0800 (PST)
In-Reply-To: <20130204090419.2e351ac5@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/02/2013 18:04, Stephen Hemminger a =E9crit :
> On Mon, 28 Jan 2013 06:47:56 -0800
> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>
>> This is usefull to know the 'real' status of an interface (the flag =
IFF_PROMISC
>> is exported by the kernel only when the user set it explicitly, for =
example it
>> will not be exported when a tcpdump is running).
>>
>> Note that I add a space after qlen (instead of before promiscuity) t=
o be
>> coherent with the rest of the code.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>   ip/ipaddress.c | 5 ++++-
>>   1 file changed, 4 insertions(+), 1 deletion(-)
>
> The idea is good, but I can't accept in the current form.
> The problem with this is that it violates the unwritten assumption th=
at the output
> of ip command should be the arguments used to setup that interface. T=
here were even
> some VPN's that depended on that.
>
Would it be acceptable to display this information when '-d' (ip -detai=
ls link)=20
is provided by the user?
