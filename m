From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [NET] [ISDN]: Do not validate ISDN net device address
	prior to interface-up
Date: Sun, 13 Apr 2008 10:51:35 +0200
Message-ID: <20080413085135.GB2788@ami.dom.local>
References: <1207839617.4311.6.camel@compaq.thuisdomein> <4801A85F.8090906@trash.net> <4801BF1C.30207@gmail.com> <4801BEB4.6090909@trash.net> <20080413082738.GA2788@ami.dom.local> <4801C3C9.4070408@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Bolle <pebolle@tiscali.nl>, netdev@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de, Jeff Garzik <jgarzik@redhat.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:2794 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754112AbYDMIq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 04:46:58 -0400
Received: by fg-out-1718.google.com with SMTP id l27so1084130fgb.17
        for <netdev@vger.kernel.org>; Sun, 13 Apr 2008 01:46:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4801C3C9.4070408@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 13, 2008 at 10:26:49AM +0200, Patrick McHardy wrote:
...
> This one is simply a bug, not a functional change.

I agree 100%. But since it worked for some people for long time...

>>  BTW, I've assisted some similar case in
>> bugzilla, and I guess users will still ask for an explanation after
>> this error code change.
>>   
>
> Well, I don't have particulary strong feelings about this, but
> I think adding a printk to one out of thousands of possible
> errors won't help much.

Maybe you are right, we can simply wait. I know Paul, me and a few
more people lost "a bit" of time because of this fix already, and
I hope the next time there will be somebody like you around to give
an advice before git bisect was finished or a few kB of logs are sent
here.

Jarek P.
