From: Anisse Astier <anisse@astier.eu>
Subject: Re: [PATCH] net: Default UDP and UNIX diag to 'n'.
Date: Tue, 7 Feb 2012 22:01:09 +0100
Message-ID: <CALUN=qKmdN=BP+edZRr50zH_rJe=twbHE7EKq6bCEptoHmBtyw@mail.gmail.com>
References: <4F31292F.2090503@parallels.com> <20120207.122931.1509587729423704935.davem@davemloft.net>
 <20120207183911.4dd65ac8@destiny.ordissimo> <20120207.133617.2073149861534644798.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@parallels.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:48012 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756533Ab2BGVBa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 16:01:30 -0500
Received: by qcqw6 with SMTP id w6so4328890qcq.19
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2012 13:01:29 -0800 (PST)
In-Reply-To: <20120207.133617.2073149861534644798.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 7, 2012 at 7:36 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: Anisse Astier <anisse@astier.eu>
> Date: Tue, 7 Feb 2012 18:39:11 +0100
>
>> On Tue, 07 Feb 2012 12:29:31 -0500 (EST), David Miller <davem@daveml=
oft.net> wrote :
>>
>>> From: Pavel Emelyanov <xemul@parallels.com>
>>> Date: Tue, 07 Feb 2012 17:37:51 +0400
>>>
>>> > @@ -409,7 +409,7 @@ config INET_TCP_DIAG
>>> >
>>> > =A0config INET_UDP_DIAG
>>> > =A0 =A0tristate "UDP: socket monitoring interface"
>>> > - =A0depends on INET_DIAG
>>> > + =A0depends on INET_DIAG && IPV6
>>>
>>> This needs to be something like "INET_DIAG && (IPV6 || IPV6=3Dn)"
>>
>> Yes, this works better. This is the right solution.
>>
>> Tested-by: Anisse Astier <anisse@astier.eu>
>
> The patch was corrupted by your email client, it turned all the
> tab characters into spaces, you also didn't write an appropriate
> commit message.
>
> I took care of this, but if you plan to submit any patch at all in
> the future, even as an "request for comments" and testing, you must
> keep these issues in mind.

Sorry, I didn't expect anyone to use this as a patch (no sign-off, etc)=
,
so I=A0shouldn't have posted a diff.
