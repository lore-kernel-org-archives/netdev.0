From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH v18 01/15] Add PR_{GET,SET}_NO_NEW_PRIVS to prevent execve
 from granting privs
Date: Fri, 13 Apr 2012 14:34:00 +1000 (EST)
Message-ID: <alpine.LRH.2.02.1204131432430.22093@tundra.namei.org>
References: <1334267284-19166-1-git-send-email-wad@chromium.org> <alpine.LRH.2.02.1204131414580.22039@tundra.namei.org> <CAObL_7ER32AesD6bHk591ss0hTFmp0bjVOKV9oEdhiFwCEVOBA@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
        linux-man@vger.kernel.org, linux-security-module@vger.kernel.org,
        linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
        kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
        x86@kernel.org, arnd@arndb.de, "David S. Miller" <davem@davemloft.net>,
        hpa@zytor.com, mingo@redhat.com, Oleg Nesterov <oleg@redhat.com>,
        peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
        tglx@linutronix.de, Eric Paris <eparis@redhat.com>,
        Serge Hallyn <serge.hallyn@canonical.com>, djm@mindrot.org,
        scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
        Andrew Morton <akpm@linux-foundation.org>,
        Jonathan Corbet <corbet@lwn.net>, eric.dumazet@gmail.com,
        markus@chromium.org, coreyb@linux.vnet.ibm.com,
        Kees Cook <keescook@chromi
To: Andrew Lutomirski <luto@mit.edu>
Return-path: <kernel-hardening-return-1270-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAObL_7ER32AesD6bHk591ss0hTFmp0bjVOKV9oEdhiFwCEVOBA@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Thu, 12 Apr 2012, Andrew Lutomirski wrote:

> > What about dynamic transitions in SELinux ?
> >
> 
> What's a dynamic transition?

The security label can be changed without an exec:

See selinux_setprocattr(), for "current".


- James
-- 
James Morris
<jmorris@namei.org>
