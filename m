From: Jes Sorensen <Jes.Sorensen@redhat.com>
Subject: Re: [PATCH] rtl8xxxu: Fix for agressive power saving by rtl8723bu wireless IC
Date: Wed, 16 Nov 2016 16:29:16 -0500
Message-ID: <wrfj60nni05v.fsf@redhat.com>
References: <20161031183522.GA13315@cube> <wrfj1sywrz2f.fsf@redhat.com>
        <CAAye0QNtcb28q1HY-xAr=bQ0s_nEQuv1TM+Ax5i99Eds7xOb=Q@mail.gmail.com>
        <CAAye0QNjYY5gBzSdc+0_rhy1OHk7iQ-CVp0Svph1DR7+mgVWGg@mail.gmail.com>
        <CAAye0QP0FQetaaa-RE23teVgZ335ELE8O5qnzMA7CwQ4T8wc_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Barry Day <briselec@gmail.com>,
        =?utf-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: John Heenan <john@zgus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34626 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753058AbcKPV3S (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Nov 2016 16:29:18 -0500
In-Reply-To: <CAAye0QP0FQetaaa-RE23teVgZ335ELE8O5qnzMA7CwQ4T8wc_Q@mail.gmail.com>
        (John Heenan's message of "Wed, 2 Nov 2016 11:13:34 +1000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Heenan <john@zgus.com> writes:
> Barry Day has submitted real world reports for the 8192eu and 8192cu.
> This needs to be acknowledged. I have submitted real world reports for
> the 8723bu.

Lets get this a little more clear - first of all, I have asked you to
investigate which part resolves the problem. Rather than 'I randomly
moved something around and it happens to work for me'.

> When it comes down to it, it looks like the kernel code changes are
> really going to be very trivial to fix this problem and we need to
> take the focus off dramatic outbursts over style issues to a strategy
> for getting usable results from real world testing.
>
> Addressing style issues in a dramatic manner to me looks like a mean
> sport for maintainers who line up to easy target first time
> contributors. This mean attitude comes from the top with a well known
> comment about "publicly making fun of people". The polite comments
> over style from Joe Perches and Rafał Miłecki are welcomed.

Once bad code is in place, it is way harder to get rid of it again. It
is *normal* for maintainers to ask contributors to do things
correctly. In addition you have been asked repeatedly by multiple people
to respect coding style, but every patch you posted violated it again in
a different way, instead of spending the little time it would take for
you to get it right.

> An effective strategy would be to insert some printk statements to
> trace what init steps vendor derived drivers do each time
> wpa_supplicant is called and ask real world testers to report their
> results. This is a lot more productive and less error prone than
> laboriously pouring over vendor source code. Alternative drivers that
> use vendor code from Realtek is enormously complicated and a huge pain
> to make sense of.
>
> Joe Sorensen's driver code is far easier to make sense of and it is a
> shame Realtek don't come to the party. Joe Sorensens's code take takes
> advantage of the excellent work of kernel contributors to the mac80211
> driver.

Now you are pissing on my name - do you really want to be taken
seriously here?

> Previous comments I made about enable_rf, rtl8xxxu_start,
> rtl8xxxu_init_device etc should be clarified. I will leave it for the
> moment as it currently serves no direct useful purpose.

I have made it very clear I want this issue resolved, but I want it
done right.

Jes
