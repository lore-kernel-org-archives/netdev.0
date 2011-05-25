From: C Anthony Risinger <anthony@xtfx.me>
Subject: Re: [GIT PULL] Namespace file descriptors for 2.6.40
Date: Wed, 25 May 2011 16:05:39 -0500
Message-ID: <BANLkTikW4vJbC8kcLSKuemUBbu36SO6hwg@mail.gmail.com>
References: <m1wrhh3z62.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1wrhh3z62.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 23, 2011 at 4:05 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> This tree adds the files /proc/<pid>/ns/net, /proc/<pid>/ns/ipc,
> /proc/<pid>/ns/uts that can be opened to refer to the namespaces of a
> process at the time those files are opened, and can be bind mounted to
> keep the specified namespace alive without a process.
>
> This tree adds the setns system call that can be used to change the
> specified namespace of a process to the namespace specified by a system
> call.

i just have a quick question regarding these, apologies if wrong place
to respond -- i trimmed to lists only.

if i understand correctly, mount namespaces (for example), allow one
to build such constructs as "private /tmp" and similar that even
`root` cannot access ... and there are many reasons `root` does not
deserve to completely know/interact with user processes (FUSE makes a
good example ... just because i [user] have SSH access to a machine,
why should `root`?)

would these /proc additions break such guarantees?  IOW, would it now
become possible for `root` to inject stuff into my private namespaces,
and/or has these guarantees never existed and i am mistaken?  is there
any kind of ACL mechanism that endows the origin process (or similar)
with the ability to dictate who can hold and/or interact with these
references?

Thanks for your time,

-- 

C Anthony
