From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: fs, net: deadlock between bind/splice on af_unix
Date: Fri, 23 Jun 2017 09:30:57 -0700
Message-ID: <CAM_iQpVaqHSN3vVMZqe7=Bc924Vtm4ERVD8ZjorwLH1O9fXPQw@mail.gmail.com>
References: <CACT4Y+Z981V+QLHr=PnQy1Dvxrpp-nCDhQtf+5HuNAusH+Vqxw@mail.gmail.com>
 <065031f0-27c5-443d-82f9-2f475fcef8c3@googlegroups.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: syzkaller <syzkaller@googlegroups.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: kodamagulla.kalyan@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <065031f0-27c5-443d-82f9-2f475fcef8c3@googlegroups.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Jun 22, 2017 at 10:49 AM,  <kodamagulla.kalyan@gmail.com> wrote:
> I was getting below crash while running mp4.

Are you sure your 3.14 kernel has my patch in this thread?
commit 0fb44559ffd67de8517098 is merged in 4.10.

Also, your crash is on unix_dgram_sendmsg() path, not
unix_bind().
