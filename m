From: Markus Gutschke <markus@chromium.org>
Subject: Re: [PATCH v8 5/8] seccomp: Add SECCOMP_RET_TRAP
Date: Thu, 16 Feb 2012 12:28:25 -0800
Message-ID: <CAE6n16nUB8eg18YHdYbSUqtZ_WJduk4B_dYqyYy37K+6di6yVw@mail.gmail.com>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
 <1329422549-16407-5-git-send-email-wad@chromium.org> <CAE6n16mCrJC=Sre+PT1H_VfSjW0MGyi0xtEcdcRvGMvvwXWzmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.org,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	keescook@chromium.org
To: Will Drewry <wad@chromium.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CAE6n16mCrJC=Sre+PT1H_VfSjW0MGyi0xtEcdcRvGMvvwXWzmA@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2012 at 12:02, Will Drewry <wad@chromium.org> wrote:
> Adds a new return value to seccomp filters that triggers a SIGTRAP to be delivered with the new TRAP_SECCOMP si_code.
>
> This allows in-process system call emulation -- including just specifying an errno or cleanly dumping core -- rather than just dying.

SIGTRAP might not be the ideal choice of signal number, as it can make
it very difficult to debug the program in gdb. Other than that, I love
this feature. It'll significantly simplify the code that we have in
Chrome.


Markus
