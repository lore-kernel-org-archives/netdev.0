From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCHv7 1/5] Remove unnecessary locks from rtnetlink (in do_setlink)
Date: Fri, 30 Nov 2007 23:13:04 +0100
Message-ID: <47508AF0.7070204@o2.pl>
References: <11963527094077-git-send-email-panther@balabit.hu> <11963527103201-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:54851 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753079AbXK3WLg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 17:11:36 -0500
In-Reply-To: <11963527103201-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote, On 11/29/2007 05:11 PM:

> The do_setlink function is protected by rtnl, additional locks are unnecessary,
> and the set_operstate() function is called from protected parts. Locks removed
> from both functions.

It doesn't look like in accordance with a comment to dev_base_lock in dev.c.
And it makes eg. rfc2863_policy() locking from link_watch.c looking strange.
Isn't there needed some additional comment to this?

Regards,
Jarek P.
