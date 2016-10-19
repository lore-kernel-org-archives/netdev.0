From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC v3 05/22] bpf,landlock: Add eBPF program subtype and
 is_valid_subtype() verifier
Date: Wed, 19 Oct 2016 17:01:17 +0200
Message-ID: <20161019150117.GB22003@pox.localdomain>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-6-mic@digikod.net>
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
In-Reply-To: <20160914072415.26021-6-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/14/16 at 09:23am, Mickaël Salaün wrote:
> @@ -155,6 +163,7 @@ union bpf_attr {
>  		__u32		log_size;	/* size of user buffer */
>  		__aligned_u64	log_buf;	/* user supplied buffer */
>  		__u32		kern_version;	/* checked when prog_type=kprobe */
> +		union bpf_prog_subtype prog_subtype;	/* checked when prog_type=landlock */

The comment seems bogus, this is not landlock specific.
