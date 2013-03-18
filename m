From: Sylvain Munaut <s.munaut@whatever-company.com>
Subject: Re: Who/What is supposed to remove IPv6 address from interface when
 moving from one network to another ?
Date: Mon, 18 Mar 2013 19:28:28 +0100
Message-ID: <CAF6-1L7Von88pAhHzhyaJiL8x4w9cNpJw+k+0Giu5Jh-fYJ37g@mail.gmail.com>
References: <CAF6-1L4=xACZdqvJ6AZL4XkY17N0pC9PnPfNfK9Tk7QB47c1tw@mail.gmail.com>
	<CAF6-1L5cxguK8tHxjMACZJ8xNmAXLLXwP086eF4_SEctZdiZ3g@mail.gmail.com>
	<1363290495.1643.29.camel@dcbw.foobar.com>
	<CAKD1Yr1=1kfcSmRYgnrYQBhNPPc=nquB2c1jLbopbvqz848cxQ@mail.gmail.com>
	<1363626191.6437.2.camel@dcbw.foobar.com>
	<CAF6-1L7De=QQz9YnRxqovnoxzfR0WHnQ-Fi4T_LZ+j9s=oQWyA@mail.gmail.com>
	<CAKD1Yr1Dd0ngiB0WhEQCjCrrEVrtqs9VuHPWukCdupkfLWjqaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dan Williams <dcbw@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f49.google.com ([209.85.214.49]:44438 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754382Ab3CRS2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 14:28:30 -0400
Received: by mail-bk0-f49.google.com with SMTP id w11so2711676bku.36
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 11:28:28 -0700 (PDT)
In-Reply-To: <CAKD1Yr1Dd0ngiB0WhEQCjCrrEVrtqs9VuHPWukCdupkfLWjqaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

>> This might be a dumb idea but, would it make sense for the kernel not
>> to use as source address, an address generated from a prefix for which
>> the route has expired ?
>
> The route doesn't expire either. (And neither does the default gateway).

Ah sorry.

In my case the router lifetime is much shorter ( a few minutes ) and
expired by the time I get home, which is why I was only faced with the
"using bad source address" issue.

In anycase, following Dan's reponse, I just flush all ipv6 on suspend
now ... (NetworkManager was a bit heavy-weight to just sort that
particular issue ...)


Cheers,

   Sylvain
