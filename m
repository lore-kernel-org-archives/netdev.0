From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: Who/What is supposed to remove IPv6 address from interface when
 moving from one network to another ?
Date: Mon, 18 Mar 2013 09:51:55 -0700
Message-ID: <CAKD1Yr1=1kfcSmRYgnrYQBhNPPc=nquB2c1jLbopbvqz848cxQ@mail.gmail.com>
References: <CAF6-1L4=xACZdqvJ6AZL4XkY17N0pC9PnPfNfK9Tk7QB47c1tw@mail.gmail.com>
 <CAF6-1L5cxguK8tHxjMACZJ8xNmAXLLXwP086eF4_SEctZdiZ3g@mail.gmail.com> <1363290495.1643.29.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Sylvain Munaut <s.munaut@whatever-company.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:53594 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753610Ab3CRQwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 12:52:16 -0400
Received: by mail-oa0-f46.google.com with SMTP id k1so5881754oag.33
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 09:52:16 -0700 (PDT)
In-Reply-To: <1363290495.1643.29.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 14, 2013 at 12:48 PM, Dan Williams <dcbw@redhat.com> wrote:
> The kernel does not (and shouldn't) trigger anything on carrier change as that's a
> site-specific/user-specific policy.

Actually, it *does* trigger events on carrier change: it creates the
addresses when you connect. It just doesn't delete them when you
disconnect. So you can get addresses without a userspace daemon, but
you can never delete them without a userspace daemon.

I tried to argue that that's incorrect, but, well, the archives show
how far I got.
