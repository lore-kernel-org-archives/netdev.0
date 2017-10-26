From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: BUG: unable to handle kernel paging request in vsock_diag_dump
Date: Thu, 26 Oct 2017 10:18:52 +0200
Message-ID: <20171026081852.GA31901@stefanha-x1.localdomain>
References: <001a113f99fe969d68055c4c63a3@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kvm@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        syzkaller-bugs@googlegroups.com,
        virtualization@lists.linux-foundation.org
To: syzbot
        <bot+d6b6d5e0ac5609c835098f88c893a7bb3cfa0900@syzkaller.appspotmail.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <001a113f99fe969d68055c4c63a3@google.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 24, 2017 at 08:14:01AM -0700, syzbot wrote:
> Hello,
> 
> syzkaller hit the following crash on
> 28f50eb20931f32a2ceeb6aba8fa2cd5ca96ad9f
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers
> 
> 
> IP: read_pnet include/net/net_namespace.h:269 [inline]
> IP: sock_net include/net/sock.h:2299 [inline]
> IP: vsock_diag_dump+0x290/0xa80 net/vmw_vsock/diag.c:87

Feel free to ignore my previous reply, Cong Wang
<xiyou.wangcong@gmail.com> has already found the root cause.  Thank you!

Stefan
