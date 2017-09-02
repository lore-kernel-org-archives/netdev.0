From: Djalal Harouni <tixxdz@gmail.com>
Subject: Re: [PATCH v4 next 1/3] modules:capabilities: allow
 __request_module() to take a capability argument
Date: Sat, 2 Sep 2017 08:31:05 +0200
Message-ID: <CAEiveUdQzHjG0OSvG=63PBOmjL19f5-qM8Fap51xSM5eDUcihw@mail.gmail.com>
References: <1495454226-10027-1-git-send-email-tixxdz@gmail.com>
 <1495454226-10027-2-git-send-email-tixxdz@gmail.com> <CAGXu5jL9jRDkHj20kf4O6VrjiEpvXGzN3nn5Lw4fT2sx_Xg=+A@mail.gmail.com>
 <CAEiveUe5cTCet6=Uzn64YANRZ2Qyqk5OSXqU3MybevbkbeNR3Q@mail.gmail.com>
 <CAGXu5j+L1aEWqi7DC4StwAorfG4da0XqrouMvbz07cJ7gYi0AQ@mail.gmail.com>
 <CAEiveUeZhHtPyLv8=3BsPh5Anr2ynnzD0bprUkeKUGygtRQKsw@mail.gmail.com>
 <CAGXu5jK5exWBV+ub8ys86Ubu1vKwN=miOZxwp3zdWaWEfuJddQ@mail.gmail.com>
 <CAEiveUeKU-zxXUeeuTZ2Sf1NrbH+t9JjwaWOK_2varRDsfbEWg@mail.gmail.com> <CAGXu5jJPk5a_66FpMd6D-XdWyzD7sxCPQirz1C6_hEFu4qsP5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Serge E. Hallyn" <serge@hallyn.com>,
        Rusty Russell <rusty@rustcorp.com.au>,
        "David S . Miller" <davem@davemloft.net>,
        Jessica Yu <jeyu@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-security-module <linux-security-module@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Andy Lutomirski <luto@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <paul@paul-moore.com>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
        Ingo Molnar <mingo@kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        Dongsu Park <dpar
To: Kees Cook <keescook@google.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jJPk5a_66FpMd6D-XdWyzD7sxCPQirz1C6_hEFu4qsP5g@mail.gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kees,

On Thu, Jun 1, 2017 at 9:10 PM, Kees Cook <keescook@google.com> wrote:
> On Thu, Jun 1, 2017 at 7:56 AM, Djalal Harouni <tixxdz@gmail.com> wrote:
...
>
>> BTW Kees, also in next version I won't remove the
>> capable(CAP_NET_ADMIN) check from [1]
>> even if there is the new request_module_cap(), I would like it to be
>> in a different patches, this way we go incremental
>> and maybe it is better to merge what we have now ?  and follow up
>> later, and of course if other maintainers agree too!
>
> Yes, incremental. I would suggest first creating the API changes to
> move a basic require_cap test into the LSM (which would drop the
> open-coded capable() checks in the net code), and then add the
> autoload logic in the following patches. That way the "infrastructure"
> changes happen separately and do not change any behaviors, but moves
> the caps test down where its wanted in the LSM, before then augmenting
> the logic.
>
>> I just need a bit of free time to check again everything and will send
>> a v5 with all requested changes.
>
> Great, thank you!
>

So sorry was busy these last months, I picked it again, will send v5 after the
merge window.

Kees I am looking on a way to integrate a test for it, we should use
something like
the example here [1] or maybe something else ? and which module to use ?

I still did not sort this out, if anyone has some suggestions, thank
you in advance!


[1] http://openwall.com/lists/kernel-hardening/2017/05/22/7

-- 
tixxdz
