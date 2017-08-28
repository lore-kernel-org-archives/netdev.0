From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH net-next v7 04/10] bpf: Define handle_fs and add a new
 helper bpf_handle_fs_get_mode()
Date: Mon, 28 Aug 2017 14:09:36 +1000 (AEST)
Message-ID: <alpine.LRH.2.20.1708281408430.8842@namei.org>
References: <20170821000933.13024-1-mic@digikod.net> <20170821000933.13024-5-mic@digikod.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="1665246916-1775300426-1503893377=:8842"
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
        Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
To: =?ISO-8859-15?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <kernel-hardening-return-9574-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170821000933.13024-5-mic@digikod.net>
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1665246916-1775300426-1503893377=:8842
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Mon, 21 Aug 2017, Mickaël Salaün wrote:

> @@ -85,6 +90,8 @@ enum bpf_arg_type {
>  
>  	ARG_PTR_TO_CTX,		/* pointer to context */
>  	ARG_ANYTHING,		/* any (initialized) argument is ok */
> +
> +	ARG_CONST_PTR_TO_HANDLE_FS,	/* pointer to an abstract FS struct */
>  };

Looks like a spurious empty line.

-- 
James Morris
<jmorris@namei.org>

--1665246916-1775300426-1503893377=:8842--
