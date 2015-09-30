From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: [PATCH v3 4/5] kcmp: add KCMP_FILE_PRIVATE_DATA
Date: Wed, 30 Sep 2015 12:41:29 -0600
Message-ID: <20150930184129.GB23065@smitten>
References: <1443636820-17083-1-git-send-email-tycho.andersen@canonical.com>
 <1443636820-17083-5-git-send-email-tycho.andersen@canonical.com>
 <CALCETrUosV+ND1BC-qH3xZMaLwnex50SvMhaSa3FQ19oy1MBVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux API <linux-api@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrUosV+ND1BC-qH3xZMaLwnex50SvMhaSa3FQ19oy1MBVg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 30, 2015 at 11:25:41AM -0700, Andy Lutomirski wrote:
> On Wed, Sep 30, 2015 at 11:13 AM, Tycho Andersen
> <tycho.andersen@canonical.com> wrote:
> > This command allows comparing the underling private data of two fds. This
> > is useful e.g. to find out if a seccomp filter is inherited, since struct
> > seccomp_filter are unique across tasks and are the private_data seccomp
> > fds.
> 
> This is very implementation-specific and may have nasty ABI
> consequences far outside seccomp.  Let's do something specific to
> seccomp and/or eBPF.

We could change the name to a less generic KCMP_SECCOMP_FD or
something, but without some sort of GUID on each struct
seccomp_filter, the implementation would be effectively the same as it
is today. Is that enough, or do we need a GUID?

Tycho
