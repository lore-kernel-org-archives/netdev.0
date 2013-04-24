From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH] x86: make DR*_RESERVED unsigned long
Date: Wed, 24 Apr 2013 11:45:01 -0700
Message-ID: <5178282D.9030902@zytor.com>
References: <CA+55aFwpLu0qNms=hkQr43yqD0K9DgESNm91OEWKT1ZuT8MU6Q@mail.gmail.com> <20130424072630.GB1780@gmail.com> <20130424170702.GA1867@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
	Fr??d??ric Weisbecker <fweisbec@gmail.com>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130424170702.GA1867@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/24/2013 10:07 AM, Oleg Nesterov wrote:
> DR6_RESERVED and DR_CONTROL_RESERVED are used to clear the set
> bits in the "unsigned long" data, make them long to ensure that
> "&~" doesn't clear the upper bits.
> 
> do_debug() and ptrace_write_dr7() which use DR*_RESERVED look
> safe, but probably it makes sense to cleanup anyway.
> 
> Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>

Can you please put in the description if this is a manifest or
non-manifest bug and, if manifest, what the issues are?  It greatly
affects what we otherwise have to do to address the bug.

Also, the -UL suffix is usually capitalized in our codebase.

	-hpa
