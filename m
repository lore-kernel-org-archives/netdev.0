From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH net] bpf: split eBPF out of NET
Date: Fri, 24 Oct 2014 10:19:29 +0200
Message-ID: <CAMuHMdURm_6Mx8d4hh+TvAHLnC_nQ_0jfLGhjDw5pru2eVWyvw@mail.gmail.com>
References: <1414114868-28228-1-git-send-email-ast@plumgrid.com>
	<20141024032355.GB7879@thin>
	<CAMEtUuxsk=iLDsD4XXZ8EcurFXgFxD-9iePv=NbBZn+b3YOXJA@mail.gmail.com>
	<20141024081139.GA8861@thin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Josh Triplett <josh@joshtriplett.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141024081139.GA8861@thin>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 24, 2014 at 10:11 AM, Josh Triplett <josh@joshtriplett.org> wrote:
>> >> +config BPF_SYSCALL
>> >> +     bool "Enable bpf() system call" if EXPERT
>> >> +     select ANON_INODES
>> >> +     select BPF
>> >> +     default n
>> >> +     help
>> >> +       Enable the bpf() system call that allows to manipulate eBPF
>> >> +       programs and maps via file descriptors.
>> >
>> > Not sure this one goes under EXPERT, especially since it currently has
>> > "default n".
>>
>> I followed the same style as EPOLL, EVENTFD and others
>> in the same category.
>
> I was thinking of CROSS_MEMORY_ATTACH and FHANDLE in the same file.

Those indeed look like better examples.
With if EXPERT and default n, you need to enable EXPERT before you can
enable the syscall, which is probably not what you want.

Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
