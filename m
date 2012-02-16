From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH v8 5/8] seccomp: Add SECCOMP_RET_TRAP
Date: Thu, 16 Feb 2012 13:23:47 -0800
Message-ID: <4F3D73E3.7070409@zytor.com>
References: <1329422549-16407-1-git-send-email-wad@chromium.org> <1329422549-16407-5-git-send-email-wad@chromium.org> <CAE6n16mCrJC=Sre+PT1H_VfSjW0MGyi0xtEcdcRvGMvvwXWzmA@mail.gmail.com> <CAE6n16nUB8eg18YHdYbSUqtZ_WJduk4B_dYqyYy37K+6di6yVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.org, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, keescook@chromium.org
To: Markus Gutschke <markus@chromium.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CAE6n16nUB8eg18YHdYbSUqtZ_WJduk4B_dYqyYy37K+6di6yVw@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/16/2012 12:28 PM, Markus Gutschke wrote:
> On Thu, Feb 16, 2012 at 12:02, Will Drewry <wad@chromium.org> wrote:
>> Adds a new return value to seccomp filters that triggers a SIGTRAP to be delivered with the new TRAP_SECCOMP si_code.
>>
>> This allows in-process system call emulation -- including just specifying an errno or cleanly dumping core -- rather than just dying.
> 
> SIGTRAP might not be the ideal choice of signal number, as it can make
> it very difficult to debug the program in gdb. Other than that, I love
> this feature. It'll significantly simplify the code that we have in
> Chrome.
> 

Sounds like SIGSYS to me.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

