From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups
Date: Fri, 26 Aug 2016 08:55:12 -0400
Message-ID: <20160826125512.GC16906@mtj.duckdns.org>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <CALCETrVqfTaY4gfwNdwynBqWwYh6xsGHaqdoA3uc_jHogbkA-A@mail.gmail.com>
 <57BF043D.4000300@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Andy Lutomirski <luto@amacapital.net>,
        LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>,
        Will Drewry <wad@chromium.org>,
        Kernel Hardening <kernel-hardening@lists.openwall.com>,
        Linux API <linux-api@vger.kernel.org>,
        LSM List <linux-security-module@vger.kernel.org>,
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57BF043D.4000300@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, Aug 25, 2016 at 04:44:13PM +0200, Mickaël Salaün wrote:
> I tested with cgroup-v2 but indeed, it seems a bit different with
> cgroup-v1 :)
> Does anyone know how to handle both cases?

If you wanna do cgroup membership test, just do cgroup v2 membership
test.  No need to introduce a new controller and possibly struct sock
association field for that.  That's what all new cgroup aware network
operations are using anyway and doesn't conflicts with whether other
controllers are v1 or v2.

For examples of using cgroup v2 membership test, please take a look at
cgroup_mt_v1().

Thanks.

-- 
tejun
