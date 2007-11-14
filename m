From: "Fabio Comolli" <fabio.comolli@gmail.com>
Subject: Re: [BUG] New Kernel Bugs
Date: Wed, 14 Nov 2007 15:14:46 +0100
Message-ID: <b637ec0b0711140614s143d053ame7a3f13884c29bf4@mail.gmail.com>
References: <32209efe0711122242m3a5f081asf1c11a38b24db10c@mail.gmail.com>
	 <20071113031553.3c7b5c16.akpm@linux-foundation.org>
	 <20071114132448.GA5183@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	"Natalie Protasevich" <protasnb@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: "Pavel Machek" <pavel@ucw.cz>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20071114132448.GA5183@ucw.cz>
Content-Disposition: inline
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

FWIW, I see the same problem with another HP notebook, DV4378EA with
radeon X700 video card. It does not happen frequently but I can say
that since I disabled the tickless feature I can't reproduce the
problem anymore.

On Nov 14, 2007 2:24 PM, Pavel Machek <pavel@ucw.cz> wrote:
> Hi!
>
> > > Suspend to RAM resume hangs on a tickless (NO_HZ) kernel
> > > http://bugzilla.kernel.org/show_bug.cgi?id=9275
> > > Kernel: 2.6.23
> > > This is HP notebook nc6320 T2400 945GM
> >
> > No response from developers
>
> Maybe I'm optimistic, but I expected Ingo/Thomas to look after nohz
> problems. nohz=off highres=off fixes more than one suspend problem...
>
> ...stuff I've seen with NOHZ even without suspend (cursor blinking
> irregulary) make me think that nohz perhaps should not be used in
> production just yet...
>
>                                                         Pavel
> --
> (english) http://www.livejournal.com/~pavelmachek
> (cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
