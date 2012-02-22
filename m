From: Andrew Lutomirski <luto@mit.edu>
Subject: Re: [PATCH v10 05/11] seccomp: add system call filtering using BPF
Date: Wed, 22 Feb 2012 15:51:40 -0800
Message-ID: <CAObL_7H14aPuaMjSyoaxWxWzP_=9D1yDiO0EKk9LPi_8-GYeyw@mail.gmail.com>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
 <1329845435-2313-5-git-send-email-wad@chromium.org> <38d58caa17befe422065efe5dc451a34.squirrel@webmail.greenhost.nl>
 <1329920626.3258.174.camel@deadeye> <CABqD9hYRPQbAY2KejstrutEO_jXU3QgBB9og_ByAaFcXZx4GHg@mail.gmail.com>
 <60d94ae06f380ff088f6270c3a536ee9.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Will Drewry <wad@chromium.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org, keescook@chromium.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <60d94ae06f380ff088f6270c3a536ee9.squirrel@webmail.greenhost.nl>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 22, 2012 at 3:46 PM, Indan Zupancic <indan@nul.nu> wrote:
> On Wed, February 22, 2012 20:47, Will Drewry wrote:
>> On Wed, Feb 22, 2012 at 8:23 AM, Ben Hutchings
>>> I would have thought the way to make sure the architecture is always
>>> checked is to pack it together with the syscall number.
>
> I missed that suggestion, putting the syscall number and arch in one
> data field would indeed make it harder to not check the arch.

Is there enough room?  On x86-64 at least, rax could conceivably be
extended to 64 bits some day.  Bit 30 is already spoken for by x32.

--Andy
