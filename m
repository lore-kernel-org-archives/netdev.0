From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net] bpf: add bpf_sk_netns_id() helper
Date: Sat, 4 Feb 2017 19:25:49 -0800
Message-ID: <20170205032548.GE73775@ast-mbp.thefacebook.com>
References: <1486171342-3310547-1-git-send-email-ast@fb.com>
 <CALCETrU6hAxyTGZXn1Eo=Pcq8gxLL2=Ai=Hks5-PjDW-3HtJjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33951 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751237AbdBEDZy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 22:25:54 -0500
Received: by mail-pg0-f67.google.com with SMTP id v184so5702293pgv.1
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 19:25:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALCETrU6hAxyTGZXn1Eo=Pcq8gxLL2=Ai=Hks5-PjDW-3HtJjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 04, 2017 at 09:15:10AM -0800, Andy Lutomirski wrote:
> On Fri, Feb 3, 2017 at 5:22 PM, Alexei Starovoitov <ast@fb.com> wrote:
> > Note that all bpf programs types are global.
> 
> I don't think this has a clear enough meaning to work with.  In

Please clarify what you mean. The quoted part says
"bpf programs are global". What is not "clear enough" there?

> I think that this patch plus a minor change to prevent installing
> cgroup+bpf programs if the installer isn't in the init netns + fs ns
> would work because it would allow new, migratable semantics to be
> added down the road to relax the restriction.

Forcing installer to be in init netns is not acceptable to David
who added cgroup_sock in the first place. I'm not sure why
we have to discuss that bit in circles.
