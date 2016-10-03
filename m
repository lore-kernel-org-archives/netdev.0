From: Kees Cook <keescook@chromium.org>
Subject: Re: [RFC v2 00/10] Landlock LSM: Unprivileged sandboxing
Date: Mon, 3 Oct 2016 15:56:56 -0700
Message-ID: <CAGXu5jLp=GMpjqdCCPWeKHNseEv5DLPC7YN6EwhR1PJsei5cHw@mail.gmail.com>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <20160915091902.GA13132@amd> <57E16D07.4050301@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Pavel Machek <pavel@ucw.cz>, LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>,
        Will Drewry <wad@chromium.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Linux API <linux-api@vger.kernel.org>,
        linux-security-module <linux-security-modu
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <57E16D07.4050301@digikod.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 20, 2016 at 10:08 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net=
> wrote:
>
> On 15/09/2016 11:19, Pavel Machek wrote:
>> Hi!
>>
>>> This series is a proof of concept to fill some missing part of seccomp =
as the
>>> ability to check syscall argument pointers or creating more dynamic sec=
urity
>>> policies. The goal of this new stackable Linux Security Module (LSM) ca=
lled
>>> Landlock is to allow any process, including unprivileged ones, to creat=
e
>>> powerful security sandboxes comparable to the Seatbelt/XNU Sandbox or t=
he
>>> OpenBSD Pledge. This kind of sandbox help to mitigate the security impa=
ct of
>>> bugs or unexpected/malicious behaviors in userland applications.
>>>
>>> The first RFC [1] was focused on extending seccomp while staying at the=
 syscall
>>> level. This brought a working PoC but with some (mitigated) ToCToU race
>>> conditions due to the seccomp ptrace hole (now fixed) and the non-atomi=
c
>>> syscall argument evaluation (hence the LSM hooks).
>>
>> Long and nice description follows. Should it go to Documentation/
>> somewhere?
>>
>> Because some documentation would be useful...
>>                                                               Pavel
>
> Right, but I was looking for feedback before investing in documentation. =
:)

Heh, understood. There are a number of grammar issues that slow me
down when reading this, so when it does move into Documentation/, I'll
have some English nit-picks. :)

While reading I found myself wanting an explicit list of "guiding
principles" for anyone implementing new hooks. It is touched on in
several places (don't expose things, don't allow for privilege
changes, etc). Having that spelled out somewhere would be nice.

-Kees

--=20
Kees Cook
Nexus Security
