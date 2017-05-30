From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: net: use-after-free in __ns_get_path
Date: Tue, 30 May 2017 07:26:48 +0100
Message-ID: <20170530062638.GD6365@ZenIV.linux.org.uk>
References: <CAAeHK+xS17Mf-9Tkup6mOYUqgq3w3V5ELG1bWQVf5jL2NJy7Lw@mail.gmail.com>
 <CAM_iQpWG1Otj7FU_TcZqEt9kEuNYU0ihkPyXeCQQEBNUhwnoCw@mail.gmail.com>
 <CACT4Y+Z0x4EGT_C=EjMF_mpkYYT7SS_mF-ZE8OxJn4oHT8F1Vg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+Z0x4EGT_C=EjMF_mpkYYT7SS_mF-ZE8OxJn4oHT8F1Vg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 29, 2017 at 04:46:23PM +0200, Dmitry Vyukov wrote:

> Al, ping.

See commit 073c516ff735.  Can you still trigger that on the
current mainline?
