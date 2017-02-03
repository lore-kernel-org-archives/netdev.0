From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Fri, 3 Feb 2017 15:21:56 -0800
Message-ID: <20170203232154.GA30114@ast-mbp.thefacebook.com>
References: <CALCETrW+ZQ1xMEfdEOzx6RK9ZoCvQiqQSnOyhDJ=-FZMwUbucg@mail.gmail.com>
 <20170118224120.GG9171@mtj.duckdns.org>
 <CALCETrXv3k+=C=9D5YGypzPk8_f4yo8ShQ3tM2fOo++gJFBM4A@mail.gmail.com>
 <20170119005925.GA18554@mtj.duckdns.org>
 <CALCETrVrEnL4cvkdDu2LUhxmeOZ+SMEmF=yKKsm9OYoW2y1Kpg@mail.gmail.com>
 <20170120023907.GA3294@ast-mbp.thefacebook.com>
 <CALCETrV6NArtFa89iW+QO3udxpJYpMXLbOEk6ZYyWsw7oZDS2Q@mail.gmail.com>
 <20170123043154.GA93519@ast-mbp.thefacebook.com>
 <CALCETrXK65itdDqYTdhB-Td8d-Hzj00dcDScUOUh9psCZN_cLA@mail.gmail.com>
 <CALCETrVQyzoCDV5u_mui7KKCwLZ4+gJQFpjvz3XuNtvVTOqRcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        David Ahern <dsahern@gmail.com>,
        Andy Lutomirski <luto@kernel.org>,
        Daniel Mack <daniel@zonque.org>,
        =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        Kees Cook <keescook@chromium.org>, Jann Horn <jann@thejh.net>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Linux API <linux-api@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrVQyzoCDV5u_mui7KKCwLZ4+gJQFpjvz3XuNtvVTOqRcQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 03, 2017 at 01:07:39PM -0800, Andy Lutomirski wrote:
> 
> Is there any plan to address this?  If not, I'll try to write that
> patch this weekend.

yes. I'm working on 'disallow program override' flag.
It got stalled, because netns discussion got stalled.
Later today will send a patch for dev_id+inode and
will continue on the flag patch.
