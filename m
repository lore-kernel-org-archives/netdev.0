From: Nanda Kumar <heramba85@gmail.com>
Subject: Re: Default TCP Options creating problems
Date: Fri, 27 Jan 2012 21:21:54 +0530
Message-ID: <4F22C81A.8090800@gmail.com>
References: <4F22B17A.2080809@gmail.com> <1327675774.2220.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:60913 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994Ab2A0PLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 10:11:18 -0500
Received: by iacb35 with SMTP id b35so2152505iac.19
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2012 07:11:17 -0800 (PST)
In-Reply-To: <1327675774.2220.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Friday 27 January 2012 08:19 PM, Eric Dumazet wrote:
> Le vendredi 27 janvier 2012 =C3=A0 19:45 +0530, Nanda Kumar a =C3=A9c=
rit :
>> Hi,
>>
>> I am using Ubuntu 11.10 and unable to connect to my ISP login server=
=2E
>> The same is working under windows. Under linux, ISP server does not
>> respond TCP SYN packet even. I did a comparison of packet capture of
>> windows and linux and found, linux include TCP options by default.
>> After manually disabling TCP Timestamp via sysctl, the login is
>> happening fine.
>>
>> Is there any reason why TCP option is enabled by default? The same
>> problem was happening under OpenSUSE 12.1 x86_64 also. My friend
>> informed me that his android mobile is also unable to connect to ISP
>> login server.
> I am very sorry, but you should complain to your ISP, 20 years after =
RFC
> 1323, it should support it.
>
> TCP options are ... options, and as such should not be denied by a
> conformant TCP stack.
>
>
>
>

Thank you for the reply. Yes even I feel so. I have put up this issue t=
o=20
ISP.

However this issue is happening only with TCP timestamp option. All=20
other options are working fine. Any idea?

Regards,
Nandakumar
