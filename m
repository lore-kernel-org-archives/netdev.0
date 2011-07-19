From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: ping6
Date: Tue, 19 Jul 2011 15:53:09 +0200
Message-ID: <4E258C45.4040408@ans.pl>
References: <fa4b41e8992b983d77dc2b57c72431e7.squirrel@charon> <CALJXSJqwiW0b-uM0YzNnPG1V3sR3q9J4M9_hhufK+ZFWW=Gdrg@mail.gmail.com> <CALJXSJpJmyLLDEs0aLxQ8-4r+mr6y9m+wuinQsxmn+1FNYUdLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric@certus.bz, netdev@vger.kernel.org
To: =?UTF-8?B?SsOpcsO0bWUgUG91bGlu?= <jeromepoulin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:53677 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab1GSOPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 10:15:19 -0400
In-Reply-To: <CALJXSJpJmyLLDEs0aLxQ8-4r+mr6y9m+wuinQsxmn+1FNYUdLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011-07-19 04:06, J=C3=A9r=C3=B4me Poulin wrote:
> On Mon, Jul 18, 2011 at 4:23 PM,<eric@certus.bz>  wrote:
>>
>> I've found what I think is a bug in the ping6 tool. Without the -n o=
ption,
>> it puts the hostname inside the parenthesis instead of the resolved =
ip
>
> I guess this is on purpose as IPv6 has very long IP and hostnames
> should be used when possible, also, it does not show the hostname you
> typed but the resolved RDNS of the IP as in:
>
> jerome@MobileCPU ~ $ ping6 www.google.ca
> PING www.google.ca(iad04s01-in-x63.1e100.net) 56 data bytes
> 64 bytes from iad04s01-in-x63.1e100.net: icmp_seq=3D1 ttl=3D55 time=3D=
57.7 ms

Hello,

Even if so it makes no sense to me. You end up without knowing which=20
host you are pinging and a typical terminal is wide enough to display=20
even longest IPv6 addresses.

Best regards,


			Krzysztof Ol=C4=99dzki
