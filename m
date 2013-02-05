From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] Break up the single NBD lock into one per NBD device
Date: Tue, 5 Feb 2013 22:51:04 +0800
Message-ID: <CAPshTCir48mTze-pEayg5TDxcH0Tyi4=NoH-FBhnM4rgrxekfQ@mail.gmail.com>
References: <1359993343.18869.14.camel@eboracum.office.bytemark.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nicholas Thomas <nick@bytemark.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:33973 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755684Ab3BEOvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 09:51:06 -0500
Received: by mail-la0-f46.google.com with SMTP id fq12so238167lab.33
        for <netdev@vger.kernel.org>; Tue, 05 Feb 2013 06:51:04 -0800 (PST)
In-Reply-To: <1359993343.18869.14.camel@eboracum.office.bytemark.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The change was straightforward but according to David Miller it should go to
"Jens Axboe's block layer tree". You are welcome to make and submit the change
there. (I did not follow nor do I know where that tree is.)

Jerry

On Mon, Feb 4, 2013 at 11:55 PM, Nicholas Thomas <nick@bytemark.co.uk> wrote:
> Hi,
>
> I was wondering if there was any chance of resurrecting this patch:
>
> http://comments.gmane.org/gmane.linux.network/207233
>
> My use case is a Linux kernel connecting to up to 6,144 NBD devices (in
> practice, probably < 1,000 almost all the time) simultaneously - our
> current deployment has a userspace implementation of NBD, and I came
> across this patch while investigating potential scalability issues.
>
> I've not performed any benchmarks yet, but I assume the issues Jerry Chu
> mentions would affect my case too, and the asked-for changes to get it
> accepted seemed minimal.
>
> Regards,
> --
> Nick Thomas
> Bytemark Computing
>
>
>
>
>
