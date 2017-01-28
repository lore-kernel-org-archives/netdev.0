From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Sat, 28 Jan 2017 09:43:54 -0500
Message-ID: <20170128144354.GA8721@mtj.duckdns.org>
References: <CALCETrVZqqfMO+=HGgebbAJ0TY6c3XSyY1G-Ve+g3VQiEfGwyA@mail.gmail.com>
 <08f3f57e-8c51-c893-01ad-3ce23db8166d@cumulusnetworks.com>
 <CALCETrVsqktjiPkfpcm_5uL0UL2Lzr106ZteLchJVnsKH_e-aw@mail.gmail.com>
 <20170124174823.GA17813@ast-mbp.thefacebook.com>
 <CALCETrW-Sj9eM+Nm9PVpqJky_30YSGhzc8hnzmddPkhHzb5_Fg@mail.gmail.com>
 <242993d5-e27c-7177-a021-610d16b150e4@cumulusnetworks.com>
 <CALCETrXzh-7BJ4Q_oG0hBkTdK+XgDWUYe0=gLwkqG6sncskv3g@mail.gmail.com>
 <20170125001130.GA37299@ast-mbp.thefacebook.com>
 <CALCETrWEDKMMwDFWM8L7hQ=T-Ffrwvmpd2VkvaFpKHuvVLFFEA@mail.gmail.com>
 <87wpdiejjg.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@amacapital.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Andy Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33357 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751536AbdA1OoJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2017 09:44:09 -0500
Received: by mail-qt0-f195.google.com with SMTP id n13so50558001qtc.0
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2017 06:44:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <87wpdiejjg.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Eric.

On Thu, Jan 26, 2017 at 01:45:07PM +1300, Eric W. Biederman wrote:
> > Eric, does this sound okay to you?  You're the authority on exposing
> > things like namespace ids to users.
> 
> *Boggle*  Things that run across all network namespaces break any kind
>  of sense I have about thinking about them.
> 
> Running across more than one network namespace by default seems very
> broken to me.

Can you explain why that is?  Other namespaces don't behave this way.
For example, a PID namespace doesn't hide the processes at the system
level.  It just gives additional nested names to the namespaced
processes and having objects visible at the system level is very
useful for monitoring and management.  Are there inherent reasons why
network namespace should be very different from other namespaces in
this regard?

Thanks.

-- 
tejun
