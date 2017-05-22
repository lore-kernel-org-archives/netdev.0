From: Kees Cook <keescook@chromium.org>
Subject: Re: [kernel-hardening] [PATCH v4 next 0/3] modules: automatic module
 loading restrictions
Date: Mon, 22 May 2017 16:52:15 -0700
Message-ID: <CAGXu5jJcMkknwoa+ZqXrDUTnA+Y603OEf4v=0WO3kz-NH-JwSA@mail.gmail.com>
References: <1495454226-10027-1-git-send-email-tixxdz@gmail.com>
 <20170522120848.GA3003@openwall.com> <CAEiveUdqfMk4+vLg6TaEJNSGwoQHxYq0P4aqZoL4i9GgR3Vdtw@mail.gmail.com>
 <20170522164323.GA2048@openwall.com> <CAEiveUdb=yc5Gt_+pU_hfNdoNBP0JsUL1QUydNZgc2tD7n1h1w@mail.gmail.com>
 <CAGXu5jKGnG74KE-k9JPaH1bNqT5nbVioaeu_5sAKQ+4kgp-0Ng@mail.gmail.com> <CALCETrXyf3vM+NdFNcjwaOZs1KFJomuTL0DobXoH9Z68k8dknQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Djalal Harouni <tixxdz@gmail.com>,
        Solar Designer <solar@openwall.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Rusty Russell <rusty@rustcorp.com.au>,
        "Serge E. Hallyn" <serge@hallyn.com>, Jessica Yu <jeyu@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <paul@paul-moore.com>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
        Ingo Molnar <mingo@kernel.org>,
        Linux API <linux-api@vger.kernel.
To: Andy Lutomirski <luto@kernel.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <CALCETrXyf3vM+NdFNcjwaOZs1KFJomuTL0DobXoH9Z68k8dknQ@mail.gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 22, 2017 at 4:38 PM, Andy Lutomirski <luto@kernel.org> wrote:
> I think that having the un-resettable mode is unnecessary.  We should
> have option that disables loading modules entirely and cannot be
> unset.  (That means no explicit loads and not implicit loads.)  Maybe
> we already have this.  Otherwise, tightening caps needed for implicit
> loads should just be a normal yes/no setting IMO.

Yup, /proc/sys/kernel/modules_disabled already does this.

-- 
Kees Cook
Pixel Security
