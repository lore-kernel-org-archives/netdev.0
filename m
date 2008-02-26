From: "Julio Kriger" <juliokriger@gmail.com>
Subject: Re: [Netem] Fixed delay patch for netem
Date: Tue, 26 Feb 2008 09:45:31 -0200
Message-ID: <682bc30a0802260345w676f4339v3c5742e1f0bad1fd@mail.gmail.com>
References: <682bc30a0802240611r5670fc9etba66cf86a9a78113@mail.gmail.com>
	 <20080225165428.24ee90fe@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netdev@oss.sgi.com,
	netem@linux-foundation.org, netem@lists.linux-foundation.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.248]:48199 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753506AbYBZLpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 06:45:34 -0500
Received: by ag-out-0708.google.com with SMTP id 33so5564452agc.1
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2008 03:45:33 -0800 (PST)
In-Reply-To: <20080225165428.24ee90fe@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,
Answering your question: there is no diffence if (and only if) there
is no gap reordering. If there is gap reordering then packets will get
a delay of 0ms or 80ms +/- 15ms. With the patch I sent,  packets will
get a delay of 50ms or 80ms +/- 15ms.
I have read about other network emulators, like NS-2, and they have
the option of gap reordering.
As I say, I need a fixed delay of 50ms plus all the other usefull
stuff that comes with netem. And netem does not allow be nested with
himself.
Regards,
Julio


On 2/25/08, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> On Sun, 24 Feb 2008 12:11:16 -0200
> "Julio Kriger" <juliokriger@gmail.com> wrote:
>
> > Hi!
> > I have created this patch to add a fixed delay on packet filtered by
> > netem. Soon I will send the patch to iproute2.
> > This patch comes from a need I have to delay all packets 50ms, beside
> > the actual delay setting, like 30ms +- 15 ms.
>
> Why is 50ms + 30m +/- 15ms any different than 80ms +/- 15ms
>
> > This strike, IMMHO, a
> > missing point on gap reordering. If I set "gap 5 delay 10ms" every 5th
> > (10th, 15th, ...) packet to go to be sent immediately and every other
> > packet to be delayed by 10ms. This  is ok, but I also need a "fixed"
> > delay of 50ms to be applied to all packets. Since netem can't be
> > nested with himself (so I can do a fixed delay), I needed this new
> > feature on netem.
>
> The gap stuff is an awkward interface that should/could have been
> done better.
>
> > This patch was create with linux kernel version 2.6.24.2.
> > I hope you like it, and it would be great if it goes shiped with the
> > next version of the kernel :-))
> > Regards,
> > Julio Kriger
>
> Maybe, but it is getting confusing with all the growth of parameters.
> Probably time for a rethink.
>


-- 
--
>From the moment I picked your book up until I laid it down, I was
convulsed with laughter. Someday I intend reading it.
Groucho Marx
----------------------------
Julio Kriger
mailto:juliokriger@gmail.com
