From: Alban Crequy <alban.crequy@gmail.com>
Subject: Re: [PATCH net-next v7 08/10] bpf: Add a Landlock sandbox example
Date: Fri, 1 Sep 2017 12:25:24 +0200
Message-ID: <CAMXgnP64XxJGLyWqqNQ7P-Ok+UDydb+t8Pm9dUyXZ_9cx+Cfmw@mail.gmail.com>
References: <20170821000933.13024-1-mic@digikod.net> <20170821000933.13024-9-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Jann Horn <jann@thejh.net>, Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>,
        Shuah Khan <shuah@kernel.org>, Tejun Heo
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170821000933.13024-9-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Micka=C3=ABl,

On 21 August 2017 at 02:09, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net> wrot=
e:
> Add a basic sandbox tool to create a process isolated from some part of
> the system. This sandbox create a read-only environment. It is only
> allowed to write to a character device such as a TTY:
...
> +       /*
> +        * This check allows the action on the file if it is a directory =
or a
> +        * pipe. Otherwise, a message is printed to the eBPF log.
> +        */
> +       if (S_ISCHR(ret) || S_ISFIFO(ret))
> +               return 0;


The comment says "directory", but the code checks for "character device".

Thanks!
Alban
