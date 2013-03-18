From: Sylvain Munaut <s.munaut@whatever-company.com>
Subject: Re: Who/What is supposed to remove IPv6 address from interface when
 moving from one network to another ?
Date: Mon, 18 Mar 2013 19:11:57 +0100
Message-ID: <CAF6-1L7De=QQz9YnRxqovnoxzfR0WHnQ-Fi4T_LZ+j9s=oQWyA@mail.gmail.com>
References: <CAF6-1L4=xACZdqvJ6AZL4XkY17N0pC9PnPfNfK9Tk7QB47c1tw@mail.gmail.com>
	<CAF6-1L5cxguK8tHxjMACZJ8xNmAXLLXwP086eF4_SEctZdiZ3g@mail.gmail.com>
	<1363290495.1643.29.camel@dcbw.foobar.com>
	<CAKD1Yr1=1kfcSmRYgnrYQBhNPPc=nquB2c1jLbopbvqz848cxQ@mail.gmail.com>
	<1363626191.6437.2.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Lorenzo Colitti <lorenzo@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f42.google.com ([209.85.214.42]:47564 "EHLO
	mail-bk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628Ab3CRSL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 14:11:58 -0400
Received: by mail-bk0-f42.google.com with SMTP id jk7so2665201bkc.29
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 11:11:57 -0700 (PDT)
In-Reply-To: <1363626191.6437.2.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This might be a dumb idea but, would it make sense for the kernel not
to use as source address, an address generated from a prefix for which
the route has expired ? Like, I get a ra for 2001:1234::/64 prefix
with 2001:1234::1 gateway.  If the gateway is lost, using
2001:1234::my_mac_address as source address with another gateway I got
from another RA with a different prefix is fairely unlikely to work
... (at least most access network I know filter that)


Cheers,

    Sylvain
