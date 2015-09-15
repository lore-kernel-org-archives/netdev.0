From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [PATCH V3 2/2] debugfs: don't assume sizeof(bool) to be 4 bytes
Date: Tue, 15 Sep 2015 19:34:36 +0530
Message-ID: <20150915140436.GJ6350@linux>
References: <9b705747a138c96c26faee5218f7b47403195b28.1442305897.git.viresh.kumar@linaro.org>
 <27d37898b4be6b9b9f31b90135f8206ca079a868.1442305897.git.viresh.kumar@linaro.org>
 <1442313464.1914.21.camel@sipsolutions.net>
 <20150915110447.GI6350@linux>
 <20150915094509.46cca84d@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>,
	Rafael Wysocki <rjw@rjwysocki.net>,
	"sboyd@codeaurora.org" <sboyd@codeaurora.org>,
	"arnd@arndb.de" <arnd@arndb.de>, Mark Brown <broonie@kernel.org>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	"moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Arik Nemtsov <arik@wizery.com>,
	"open list:QUALCOMM ATHEROS ATH10K WIRELESS DRIVER" <ath10k@lists.infradead.org>,
	"open list:QUALCOMM ATHEROS ATH9K WIRELESS DRIVER" <ath9k-devel@lists.ath9k.org>,
	"Altman, Avri" <avri.altman@intel.com>,
	"open list
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20150915094509.46cca84d@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 15-09-15, 09:45, Steven Rostedt wrote:
> Then break up the patch.

That will cause build warnings between the patches due to prototype
mismatch. Maybe I should ignore get_maintainers for this patch and
just cc the lists :)

> Your Cc list is far too large, I would nack
> this patch just for that alone.

:(

> Sad part is, you didn't even Cc Linus (which I added). I believe he was
> against having bool's in structures before.

Sorry about that, I had no clue that I should explicitly include Linus
to this thread.

> Linus, This patch changes a lot of u32s into bools in structures.
> What's your take on that?
> 
> I added the patch again to the bottom of this email so that Linus may
> see it (it was cut from the email I'm replying to).

Thanks Steven.

-- 
viresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
