From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: Wiring up direct socket calls on x86_32 Linux?
Date: Tue, 30 Jun 2015 23:29:04 +0200
Message-ID: <87oajwrilb.fsf@igel.home>
References: <CALCETrUdqUm4eue2VaNPM7tkt1DSfAgo9fd-06rcys3F0q3rQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: X86 ML <x86@kernel.org>,  "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,  Alexander Larsson <alexl@redhat.com>,  Cosimo Cecchi <cosimo@endlessm.com>,  Dan Nicholson <nicholson@endlessm.com>,  Network Development <netdev@vger.kernel.org>,  libc-alpha <libc-alpha@sourceware.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <libc-alpha-return-60524-glibc-alpha=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
In-Reply-To: <CALCETrUdqUm4eue2VaNPM7tkt1DSfAgo9fd-06rcys3F0q3rQA@mail.gmail.com>
	(Andy Lutomirski's message of "Tue, 30 Jun 2015 14:14:38 -0700")
List-Id: netdev.vger.kernel.org

Andy Lutomirski <luto@amacapital.net> writes:

> Glibc people: If Linux wired up the syscalls, would glibc use them?

Not automatically.  It needs to be compatible with the configured
minimum kernel version, so runtime probing would needed to be
implemented.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
