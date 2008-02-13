From: "Natalie Protasevich" <protasnb@gmail.com>
Subject: Re: An ioctl to delete an ipv6 tunnel leads to a kernel panic
Date: Tue, 12 Feb 2008 22:00:36 -0800
Message-ID: <32209efe0802122200w21403331k953be3da80ede52b@mail.gmail.com>
References: <32209efe0802111249x16a6bbe0l4c152b3cf3aa0470@mail.gmail.com>
	 <20080212.214946.168597748.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:8365 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532AbYBMGAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 01:00:38 -0500
Received: by fg-out-1718.google.com with SMTP id e21so4297086fga.17
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2008 22:00:36 -0800 (PST)
In-Reply-To: <20080212.214946.168597748.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Feb 12, 2008 9:49 PM, David Miller <davem@davemloft.net> wrote:
> From: "Natalie Protasevich" <protasnb@gmail.com>
> Date: Mon, 11 Feb 2008 12:49:12 -0800
>
> > Possible reason for this failure was identified and tested by the
> > submitter and several other reporters that ran into the same problem.
> > Can the patch be reviewed and pushed upstream if accepted (if the
> > problem hasn't been addressed already)?
>
> There are a lot of bogus patches in there, using funny
> long variable names, and mainly they were meant for testing
> and verification of the problem.
>
> I see no real serious patch submissions in that bug and furthermore
> the patch, if ready, should be submitted formally here to netdev not
> rot in bugzilla.
>
> Finally, what appears to be the proposal cannot be correct.  If the
> fib6_add_rt2node() finds that the new route is a duplicate, we should
> disconnect it from the fn->leaf and do a dst_release().  The bug
> appears to be rather that we leave the route attached to the fn, not
> that we drop the refrence to it.
>
> Thank you.

Thanks David for looking in this. I will give this thought to the
diligent reporters, unless someone on the net team can produce a patch
for them to test.
Sometimes reporters come up with patches and I always try to make sure
the patches end up on appropriate mailing list, and I will continue
doing so :)

Regards,
--Natalie
>
