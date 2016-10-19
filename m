From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC v3 04/22] bpf: Set register type according to
 is_valid_access()
Date: Wed, 19 Oct 2016 16:54:20 +0200
Message-ID: <20161019145420.GA22003@pox.localdomain>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-5-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kern
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160914072415.26021-5-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/14/16 at 09:23am, Mickaël Salaün wrote:
> This fix a pointer leak when an unprivileged eBPF program read a pointer
> value from the context. Even if is_valid_access() returns a pointer
> type, the eBPF verifier replace it with UNKNOWN_VALUE. The register
> value containing an address is then allowed to leak. Moreover, this
> prevented unprivileged eBPF programs to use functions with (legitimate)
> pointer arguments.
> 
> This bug was not a problem until now because the only unprivileged eBPF
> program allowed is of type BPF_PROG_TYPE_SOCKET_FILTER and all the types
> from its context are UNKNOWN_VALUE.
> 
> Signed-off-by: Mickaël Salaün <mic@digikod.net>
> Fixes: 969bf05eb3ce ("bpf: direct packet access")
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Daniel Borkmann <daniel@iogearbox.net>

Can you post this fix separately? It's valid and needed outside of the
scope of this series.
