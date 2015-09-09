From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 1/6] ebpf: add a seccomp program type
Date: Wed, 09 Sep 2015 18:09:43 +0200
Message-ID: <55F059C7.9070105@iogearbox.net>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com> <1441382664-17437-2-git-send-email-tycho.andersen@canonical.com> <CAGXu5j+9YvL6XzX=x8krZbdJXFpe-3FuMu=hAZX9Ew=hYyuK7Q@mail.gmail.com> <20150904210615.GR26679@smitten> <CAGXu5jKGBuD15KBfXKoYbGB40cNsbh=Dz8GM=bmUL-oECRhzxA@mail.gmail.com> <20150909155035.GA26679@smitten> <20150909160744.GA3526@Alexeis-MBP-2.westell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Tycho Andersen <tycho.andersen@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150909160744.GA3526@Alexeis-MBP-2.westell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/09/2015 06:07 PM, Alexei Starovoitov wrote:
> On Wed, Sep 09, 2015 at 09:50:35AM -0600, Tycho Andersen wrote:
[...]
>> Thoughts?
>
> Please do not add any per-instruction hacks. None of them are
> necessary. Classic had to do extra ugly checks in seccomp only
> because verifier wasn't flexible enough.
> If you don't want to see any BPF_CALL in seccomp, just have
> empty get_func_proto() callback for BPF_PROG_TYPE_SECCOMP
> and verifier will reject all calls.
> Currently we have only two non-generic instrucitons
> LD_ABS and LD_IND that are avaialable for sockets/TC only,
> because these are legacy instructions and we had to make
> exceptions for them.

Yep, +1.
