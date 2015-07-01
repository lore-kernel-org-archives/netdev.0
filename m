From: "Tulio Magno Quites Machado Filho" <tuliom@linux.vnet.ibm.com>
Subject: Re: Wiring up direct socket calls on x86_32 Linux?
Date: Wed, 01 Jul 2015 13:19:08 -0300
Message-ID: <87twtnx343.fsf@totoro.br.ibm.com>
References: <CALCETrUdqUm4eue2VaNPM7tkt1DSfAgo9fd-06rcys3F0q3rQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: X86 ML <x86@kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Alexander Larsson <alexl@redhat.com>,
        Cosimo Cecchi <cosimo@endlessm.com>,
        Dan Nicholson <nicholson@endlessm.com>,
        Network Development <netdev@vger.kernel.org>,
        libc-alpha <libc-alpha@sourceware.org>,
        Rajalakshmi Srinivasaraghavan <raji@linux.vnet.ibm.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <libc-alpha-return-60542-glibc-alpha=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
Cc: 
In-Reply-To: <CALCETrUdqUm4eue2VaNPM7tkt1DSfAgo9fd-06rcys3F0q3rQA@mail.gmail.com>
	(Andy Lutomirski's message of "Tue, 30 Jun 2015 14:14:38 -0700")
List-Id: netdev.vger.kernel.org

Andy Lutomirski <luto@amacapital.net> writes:

> Hi all-
>
> sys_socketcall sucks.  If nothing else, it's impossible to filter with
> seccomp.  Should we wire up the real socket calls so that user code
> can (very slowly) start migrating?
>
> I think the list is:
>  - socket
>  - bind
>  - connect
>  - listen
>  - accept4
>  - getsockname
>  - getpeername
>  - socketpair
>  - send
>  - sendto
>  - sendmsg
>  - recv
>  - recvfrom
>  - recvmsg
>  - shutdown
>  - setsockopt

I guess you might want to follow the patch Raji sent today [1].

Her patch doesn't have all the syscalls you mentioned here, but has others too.
She will work to get a generic implementation for these functions.

[1] http://patchwork.sourceware.org/patch/7438/

-- 
Tulio Magno
