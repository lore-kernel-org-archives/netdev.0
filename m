From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Tue, 24 Jan 2017 14:34:37 -0700
Message-ID: <a3e24f62-de50-57f8-35a1-4761cc99dace@cumulusnetworks.com>
References: <ddd9e097f54e894197a2925731de02d1d3cae137.1485203708.git.luto@kernel.org>
 <20170124020950.GA72992@ast-mbp.thefacebook.com>
 <CALCETrUq_ZSso_252ixzjt+WbFOv_K57zbePUXneLv-Tgi5=jA@mail.gmail.com>
 <20170124031259.GA81720@ast-mbp.thefacebook.com>
 <CALCETrVZqqfMO+=HGgebbAJ0TY6c3XSyY1G-Ve+g3VQiEfGwyA@mail.gmail.com>
 <08f3f57e-8c51-c893-01ad-3ce23db8166d@cumulusnetworks.com>
 <CALCETrVsqktjiPkfpcm_5uL0UL2Lzr106ZteLchJVnsKH_e-aw@mail.gmail.com>
 <20170124174823.GA17813@ast-mbp.thefacebook.com>
 <CALCETrW-Sj9eM+Nm9PVpqJky_30YSGhzc8hnzmddPkhHzb5_Fg@mail.gmail.com>
 <242993d5-e27c-7177-a021-610d16b150e4@cumulusnetworks.com>
 <CALCETrXzh-7BJ4Q_oG0hBkTdK+XgDWUYe0=gLwkqG6sncskv3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tejun Heo <tj@kernel.org>, Andy Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36716 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750888AbdAXVek (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:34:40 -0500
Received: by mail-pf0-f179.google.com with SMTP id 189so52738656pfu.3
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 13:34:39 -0800 (PST)
In-Reply-To: <CALCETrXzh-7BJ4Q_oG0hBkTdK+XgDWUYe0=gLwkqG6sncskv3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/24/17 2:24 PM, Andy Lutomirski wrote:
> I was hoping for an actual likely use case for the bpf hooks to be run
> in all namespaces.  You're arguing that iproute2 can be made to work
> mostly okay if bpf hooks can run in all namespaces, but the use case
> of intentionally making sk_bound_dev_if invalid across all namespaces
> seems dubious.

you can use the bpf hook to deny socket create based on family and/or protocol. 
