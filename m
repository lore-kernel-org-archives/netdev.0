From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: Who/What is supposed to remove IPv6 address from interface when
 moving from one network to another ?
Date: Mon, 18 Mar 2013 11:12:54 -0700
Message-ID: <CAKD1Yr1Dd0ngiB0WhEQCjCrrEVrtqs9VuHPWukCdupkfLWjqaQ@mail.gmail.com>
References: <CAF6-1L4=xACZdqvJ6AZL4XkY17N0pC9PnPfNfK9Tk7QB47c1tw@mail.gmail.com>
 <CAF6-1L5cxguK8tHxjMACZJ8xNmAXLLXwP086eF4_SEctZdiZ3g@mail.gmail.com>
 <1363290495.1643.29.camel@dcbw.foobar.com> <CAKD1Yr1=1kfcSmRYgnrYQBhNPPc=nquB2c1jLbopbvqz848cxQ@mail.gmail.com>
 <1363626191.6437.2.camel@dcbw.foobar.com> <CAF6-1L7De=QQz9YnRxqovnoxzfR0WHnQ-Fi4T_LZ+j9s=oQWyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dan Williams <dcbw@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sylvain Munaut <s.munaut@whatever-company.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:51910 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174Ab3CRSNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 14:13:14 -0400
Received: by mail-oa0-f45.google.com with SMTP id o6so5856944oag.4
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 11:13:14 -0700 (PDT)
In-Reply-To: <CAF6-1L7De=QQz9YnRxqovnoxzfR0WHnQ-Fi4T_LZ+j9s=oQWyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 18, 2013 at 11:11 AM, Sylvain Munaut
<s.munaut@whatever-company.com> wrote:
> This might be a dumb idea but, would it make sense for the kernel not
> to use as source address, an address generated from a prefix for which
> the route has expired ?

The route doesn't expire either. (And neither does the default gateway).
