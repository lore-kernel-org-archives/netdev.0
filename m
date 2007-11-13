From: Mark Lord <liml@rtr.ca>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 08:58:58 -0500
Message-ID: <4739ADA2.4060604@rtr.ca>
References: <32209efe0711122242m3a5f081asf1c11a38b24db10c@mail.gmail.com> <20071113031553.3c7b5c16.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Natalie Protasevich <protasnb@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20071113031553.3c7b5c16.akpm@linux-foundation.org>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Mon, 12 Nov 2007 22:42:32 -0800 "Natalie Protasevich" <protasnb@gmail.com> wrote:
..
>> with CONFIG_NO_HZ and/or CONFIG_HPET_TIMER set kernel 2.6.23 doesn't
>> boot (ARM, Timer)
>> http://bugzilla.kernel.org/show_bug.cgi?id=9229
>> Kernel: 2.6.23
> 
> No response from developers
..

Note:  that same bug exists/existed on i386 back when NO_HZ was
introduced (2.6.21?).  I still see it from time to time on my Quad core
system (very rare), but not any more on my Duo notebook where it used
to happen about 1 in n boots (n < 10).

AFAICT no fix was ever released for it.



>> Suspend to RAM resume hangs on a tickless (NO_HZ) kernel
>> http://bugzilla.kernel.org/show_bug.cgi?id=9275
>> Kernel: 2.6.23
>> This is HP notebook nc6320 T2400 945GM
> No response from developers
..

I *still* get very slow resume-from-RAM quite often here
(new in 2.6.22 kernel, wasn't there in early 2.6.23-rc*).
Something eventually times out after a minute or so
and it comes back.  Cannot make it happen reliably,
unless I'm in a hurry to get something done.  :)
I suspect USB here, probably the same loopy bug that
we added a "loop limit failsafe" for back in 2.6.21(?).
