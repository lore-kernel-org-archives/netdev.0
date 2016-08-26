From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups
Date: Fri, 26 Aug 2016 11:50:26 -0400
Message-ID: <20160826155026.GD16906@mtj.duckdns.org>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <CALCETrVqfTaY4gfwNdwynBqWwYh6xsGHaqdoA3uc_jHogbkA-A@mail.gmail.com>
 <57BF043D.4000300@digikod.net>
 <CALCETrVFSbrW9VzdNirtwCXZ3-Ce1DnXoQcPgEQgbyy0=W0rEQ@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <ast@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Daniel Mack <daniel@zonque.org>,
	David Drysdale <drysdale@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	Elena Reshetova <elena.reshetova@intel.com>,
	James Morris <james.l.morris@oracle.com>,
	Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
	Sargun Dhillon <sargun@sargun.me>,
	"Serge E . Hallyn" <serge@hallyn.com>,
	Will Drewry <wad@chromium.org>,
	Kernel Hardening <kernel-hardening@lists.openwall.com>,
	Linux API <linux-api@vger.kernel.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <kernel-hardening-return-4476-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Sender: Tejun Heo <htejun@gmail.com>
Content-Disposition: inline
In-Reply-To: <CALCETrVFSbrW9VzdNirtwCXZ3-Ce1DnXoQcPgEQgbyy0=W0rEQ@mail.gmail.com>
List-Id: netdev.vger.kernel.org

Hello,

On Fri, Aug 26, 2016 at 07:20:35AM -0700, Andy Lutomirski wrote:
> > This is simply the action of changing the owner of cgroup sysfs files to
> > allow an unprivileged user to handle them (cf. Documentation/cgroup-v2.txt)
> 
> As far as I can tell, Tejun and systemd both actively discourage doing
> this.  Maybe I misunderstand.  But in any event, the admin giving you

Please refer to "2-5. Delegation" of Documentation/cgroup-v2.txt.
Delegation on v1 is broken on both core and specific controller
behaviors and thus discouraged.  On v2, delegation should work just
fine.

I haven't looked in detail but in general I'm not too excited about
layering security mechanism on top of cgroup.  Maybe it makes some
sense when security domain coincides with resource domains but at any
rate please keep me in the loop.

Thanks.

-- 
tejun
