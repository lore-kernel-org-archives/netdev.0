From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Fri, 3 Feb 2017 15:08:32 -0800
Message-ID: <20170203230830.GC26227@ast-mbp.thefacebook.com>
References: <87efzq8jbi.fsf@xmission.com>
 <588995DE.9040707@fb.com>
 <CALCETrXQ8JFV28xU7tnh3tVbe_mp5yOtHp6shi10GMNnVCQowg@mail.gmail.com>
 <588A35F8.6050909@fb.com>
 <CALCETrU7FYz=8c2a=FWvvCxFQC3_e0nYjSU6gj62w9K8mWj=Ww@mail.gmail.com>
 <588A40D7.9070603@fb.com>
 <CALCETrXgdY_Kt8wn4uiATUnNJ3YXttCUREgEeQReG7u29Lc44g@mail.gmail.com>
 <588A4D3C.9070601@fb.com>
 <87r33fevva.fsf@xmission.com>
 <CALCETrWDxVHc4_hpjLQRj-XbvGX0+tbGZ8o388-xn6rNcQTySQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Alexei Starovoitov <ast@fb.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34562 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752713AbdBCXIi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 18:08:38 -0500
Received: by mail-pg0-f65.google.com with SMTP id v184so3076353pgv.1
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 15:08:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALCETrWDxVHc4_hpjLQRj-XbvGX0+tbGZ8o388-xn6rNcQTySQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 03, 2017 at 01:00:47PM -0800, Andy Lutomirski wrote:
> 
> ISTM any ability to migrate namespaces and to migrate eBPF programs
> that know about namespaces needs to have the eBPF program firmly
> rooted in some namespace (or perhaps cgroup in this case) so that it

programs are already global. We cannot break that.

> can see a namespaced view of the world.  For this to work, presumably
> we need to make sure that eBPF programs that are installed by programs
> that are in a container don't see traffic that isn't in that
> container.

such approach will break existing users.
