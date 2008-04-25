From: "Michael Kerrisk" <mtk.manpages@gmail.com>
Subject: Re: [PATCH] socket, socketpair w/flags, accept4
Date: Fri, 25 Apr 2008 08:43:05 +0200
Message-ID: <517f3f820804242343g22700872tf31f0c15047e70e2@mail.gmail.com>
References: <200804241820.m3OIKlMK017580@devserv.devel.redhat.com>
	 <20080425042957.GA17699@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ulrich Drepper" <drepper@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	"Michael Kerrisk" <mtk.manpages@gmail.com>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	"Jakub Jelinek" <jakub@redhat.com>
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:21447 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755098AbYDYGnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 02:43:09 -0400
Received: by fg-out-1718.google.com with SMTP id l27so3468693fgb.17
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 23:43:06 -0700 (PDT)
In-Reply-To: <20080425042957.GA17699@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/25/08, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> Hi.
>
>
>  On Thu, Apr 24, 2008 at 02:20:47PM -0400, Ulrich Drepper (drepper@redhat.com) wrote:
>  > The code changes are really minimal.  And don't get too hung up on the
>  > internal name of the syscall.  I think accept4 is more desriptive than
>  > paccept since a) suffixes more easily indicate derived functionality
>  > and b) the 4 actually indicates to the initiated what has changed.
>  > If there are good reasons otherwise the userlevel interface can still
>  > be something completely different.
>
>
> What about sigset there too?

Right.  That was what I was understanding that Alan referred to when
he was talking about paccept()
