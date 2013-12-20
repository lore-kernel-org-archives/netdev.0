From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net, gro: fix the truesize of all fragments
Date: Fri, 20 Dec 2013 06:42:51 -0800
Message-ID: <1387550571.19078.436.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387539943-25521-1-git-send-email-zwu.kernel@gmail.com>
	 <1387549695.19078.430.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEH94LhaDy5TC38jNYEif3TYXy4VCBKQ0GrBuu8PUXrNNDhC1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:55866 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694Ab3LTOmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 09:42:53 -0500
Received: by mail-pa0-f45.google.com with SMTP id fb1so2718121pad.32
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 06:42:52 -0800 (PST)
In-Reply-To: <CAEH94LhaDy5TC38jNYEif3TYXy4VCBKQ0GrBuu8PUXrNNDhC1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-20 at 22:37 +0800, Zhi Yong Wu wrote:
> On Fri, Dec 20, 2013 at 10:28 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > Nope, this patch is not needed.
> >
> > truesize is about tracking the memory we allocated, not the memory we
> > really use.
> wow, i forgot this, thanks for yor reminder.
> >
> > What exact issue do you have ? I suspect a bug in a driver.
> I didn't hit any issue, but found this when i read gro related code. a
> but in a driver? sorry, i don't know, look forward to seeing your fix.

No, I have no particular issue with this code, I thought you had a
problem on a running machine.

If you found this by code review, then everything is fine, and
no patch is needed at this point.

Thanks
