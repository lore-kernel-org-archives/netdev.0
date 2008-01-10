From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take2] Re: Nested VLAN causes recursive locking error
Date: Thu, 10 Jan 2008 22:08:16 +0100
Message-ID: <20080110210816.GA3064@ami.dom.local>
References: <20080102234107.GA6902@ami.dom.local> <47863A4A.6070303@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Amorsen <benny+usenet@amorsen.dk>,
	Chuck Ebbert <cebbert@redhat.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:28030 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753873AbYAJVFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 16:05:35 -0500
Received: by fk-out-0910.google.com with SMTP id z23so633358fkz.5
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 13:05:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47863A4A.6070303@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 10, 2008 at 04:31:22PM +0100, Patrick McHardy wrote:
...
> No, this seems fine, thanks. Even better would be a way to get
> the last lockdep subclass through lockdep somehow, but I couldn't
> find a clean way for this. So I've applied your patch and also
> fixed macvlan.

As a matter of fact this simplified version was done mainly to remove
this bad looking effect of a never decreased global. Of course, your
proposal with using parent's subclass + 1 would be better, if deeper
nestings are required: so, I could try to enhance this (probably with
such additional lockdep macro) after some hint.

But still some 'quirks' are possible there: removing and adding
devices 'properly' would often require resetting of many subclasses,
so quite a lot of activities if more devices. And probably not very
common if not requested until now...

Thanks,
Jarek P.
