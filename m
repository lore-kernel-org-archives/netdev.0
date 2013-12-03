From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Wed, 4 Dec 2013 00:22:08 +0200
Message-ID: <CAJZOPZL2dq2c=5tmx+2VHX9eD1gG=pqyiQcvCvCGT+_3SDFKkQ@mail.gmail.com>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
	<1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com>
	<20131203.165034.1085515763685633822.davem@davemloft.net>
	<1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Jerry Chu <hkchu@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:46393 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754476Ab3LCWWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 17:22:08 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so21793074pbc.7
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 14:22:08 -0800 (PST)
In-Reply-To: <1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 3, 2013 at 11:55 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2013-12-03 at 16:50 -0500, David Miller wrote:
>
>> At this point I would use drop monitor to figure out in what context
>> packets are being dropped on the floor.  There are scripts provided
>> with the perf tool to utilize it.
>
> Most easy way is to do :
>
> perf record -e skb:kfree_skb -a -g sleep 10

some typo here? I tried the perf tool that comes with the net git

./perf record -e skb:kfree_skb -a -g sleep 10
invalid or unsupported event: 'skb:kfree_skb'
Run 'perf list' for a list of valid events

 usage: perf record [<options>] [<command>]
    or: perf record [<options>] -- <command> [<options>]

    -e, --event <event>   event selector. use 'perf list' to list
available events

>
> perf report
>
>
>


anything critical missing here?

perf]# make
  BUILD:   Doing 'make -j16' parallel build

Auto-detecting system features:
...                     backtrace: [ on  ]
...                         dwarf: [ on  ]
...                fortify-source: [ on  ]
...                         glibc: [ on  ]
...                          gtk2: [ OFF ]
...                  gtk2-infobar: [ OFF ]
...                      libaudit: [ OFF ]
...                        libbfd: [ on  ]
...                        libelf: [ on  ]
...             libelf-getphdrnum: [ on  ]
...                   libelf-mmap: [ on  ]
...                       libnuma: [ OFF ]
...                       libperl: [ on  ]
...                     libpython: [ on  ]
...             libpython-version: [ on  ]
...                      libslang: [ on  ]
...                     libunwind: [ OFF ]
...                       on-exit: [ on  ]
...                stackprotector: [ on  ]
...            stackprotector-all: [ on  ]
...                       timerfd: [ on  ]

config/Makefile:329: No libunwind found, disabling post unwind
support. Please install libunwind-dev[el] >= 1.1
config/Makefile:354: No libaudit.h found, disables 'trace' tool,
please install audit-libs-devel or libaudit-dev
config/Makefile:381: GTK2 not found, disables GTK2 support. Please
install gtk2-devel or libgtk2.0-dev
config/Makefile:536: No numa.h found, disables 'perf bench numa mem'
benchmark, please install numa-libs-devel or libnuma-dev
