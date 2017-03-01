From: Eric Dumazet <edumazet@google.com>
Subject: Re: net/ipv4: inconsistent lock state in tcp_conn_request/inet_ehash_insert
Date: Wed, 1 Mar 2017 07:13:57 -0800
Message-ID: <CANn89iKK9_Gao1fZ9mJEujBFMvZuOu534PE-VnSKUBkpYzr7qw@mail.gmail.com>
References: <CAAeHK+xe+5Kr4-jd7zhBgX=3VrsTB4p8Lz0F5bTtW21vVT=Hag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+xe+5Kr4-jd7zhBgX=3VrsTB4p8Lz0F5bTtW21vVT=Hag@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 1, 2017 at 6:59 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while fuzzing the kernel with syzkaller.
>
> On commit e5d56efc97f8240d0b5d66c03949382b6d7e5570 (Feb 26).

SInce I probably added this bug, I will send a fix shortly, thanks for
the report.
