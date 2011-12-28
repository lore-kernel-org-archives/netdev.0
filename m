From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next 00/23] TIPC: Updates for what will be v3.3
Date: Tue, 27 Dec 2011 21:16:10 -0500
Message-ID: <CAP=VYLpwswOktVAu1qp36KvKWKk1Shq+3Hamg4bmgkDxzArNEQ@mail.gmail.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
	<20111227.130807.1680254459456306555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:48326 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626Ab1L1CQL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 21:16:11 -0500
Received: by eaad14 with SMTP id d14so5088354eaa.19
        for <netdev@vger.kernel.org>; Tue, 27 Dec 2011 18:16:10 -0800 (PST)
In-Reply-To: <20111227.130807.1680254459456306555.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 27, 2011 at 1:08 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Paul Gortmaker <paul.gortmaker@windriver.com>
> Date: Tue, 27 Dec 2011 12:39:19 -0500
>
>> Here are some more updates for TIPC, based on the backlog of stuff
>> that was unfortunately stacked away in sourceforge a while ago.
>>
>> Given the timing, please feel free to defer these to the for-3.4
>> net-next if there isn't a convenient opportunity to process it
>> before 3.2 is officially released. =A0I can easily resend later.
>>
>> Fortunately, the SF backlog will finally be 100% gone with the
>> pending stuff that will be sent in the next year for the 3.4
>> net-next, so that will be nice to have that task closed out.
>>
>> I just finished testing this over the wire between an x86-32 and
>> an x86-64 box, with both taking turns being server and client.
>
> Pulled, thanks Paul.
>
> Two suggestions:
>
> 1) Please rename things like "struct media" to something more global
> =A0 namespace friendly like "struct tipc_media"

Yep, I can do that easily, and probably send that out this week,
since a change like this won't invalidate any prev. testing etc.

>
> 2) We really should get rid of the ad-hoc debug logging facility tipc
> =A0 uses. =A0It's not like there aren't tons of generic, well maintai=
ned,
> =A0 feature-full logging facilities available. =A0There is no reason =
for
> =A0 tipc to have it's own special, private, logginc facility.

Sounds like the right thing to do; I will take a look at this to see
how involved it is.  I don't think there should be any problem
getting it in with the remaining SF changes for 3.4 content in
the new year.

Thanks,
Paul.

>
> =A0 If the generic facilities lack some feature, add it and submit
> =A0 it for inclusion to linux-kernel so everyone can use it, not just
> =A0 TIPC.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
