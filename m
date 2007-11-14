From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [BUG] New Kernel Bugs
Date: Wed, 14 Nov 2007 13:24:48 +0000
Message-ID: <20071114132448.GA5183@ucw.cz>
References: <32209efe0711122242m3a5f081asf1c11a38b24db10c@mail.gmail.com> <20071113031553.3c7b5c16.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Natalie Protasevich <protasnb@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, alsa-devel@alsa-project.org,
	linux-ide@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
Content-Disposition: inline
In-Reply-To: <20071113031553.3c7b5c16.akpm@linux-foundation.org>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

Hi!

> > Suspend to RAM resume hangs on a tickless (NO_HZ) kernel
> > http://bugzilla.kernel.org/show_bug.cgi?id=9275
> > Kernel: 2.6.23
> > This is HP notebook nc6320 T2400 945GM
> 
> No response from developers

Maybe I'm optimistic, but I expected Ingo/Thomas to look after nohz
problems. nohz=off highres=off fixes more than one suspend problem...

...stuff I've seen with NOHZ even without suspend (cursor blinking
irregulary) make me think that nohz perhaps should not be used in
production just yet...

							Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
