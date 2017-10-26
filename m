From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: KASAN: slab-out-of-bounds Read in tipc_nametbl_lookup_dst_nodes
Date: Thu, 26 Oct 2017 11:36:59 -0700
Message-ID: <CAM_iQpVu2yePkdyo2ka5c8WRgDn1gwgN3ONqohkQ0f6WNs5V8w@mail.gmail.com>
References: <001a113ff33e3aa97d055c4c7cd8@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Jon Maloy <jon.maloy@ericsson.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        syzkaller-bugs@googlegroups.com,
        tipc-discussion@lists.sourceforge.net,
        Ying Xue <ying.xue@windriver.com>
To: syzbot
        <bot+a9d6dccad76c3e1f6cad1031d8f2292c4f4f0e1a@syzkaller.appspotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:52350 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932309AbdJZShU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 14:37:20 -0400
In-Reply-To: <001a113ff33e3aa97d055c4c7cd8@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

#syz fix: tipc: eliminate KASAN warning
