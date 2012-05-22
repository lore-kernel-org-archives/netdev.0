From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at net/ipv4/tcp.c:1301 tcp_cleanup_rbuf+0x4f/0x110()
Date: Tue, 22 May 2012 16:33:23 +0200
Message-ID: <1337697203.3361.190.camel@edumazet-glaptop>
References: <CAJyhjX22Vna=TwuhD-FqyoXEd9D8wq_VdHbAAWwmqO1hZ34FRA@mail.gmail.com>
	 <CAJyhjX1VKQpAbqkxnWFNrRSVBuSRYaNQSUXYWqYfoE0GnmVokQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sergio Correia <lists@uece.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38916 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753040Ab2EVOd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 10:33:28 -0400
Received: by bkcji2 with SMTP id ji2so5039380bkc.19
        for <netdev@vger.kernel.org>; Tue, 22 May 2012 07:33:27 -0700 (PDT)
In-Reply-To: <CAJyhjX1VKQpAbqkxnWFNrRSVBuSRYaNQSUXYWqYfoE0GnmVokQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-22 at 10:57 -0300, Sergio Correia wrote:
> On Tue, May 22, 2012 at 2:43 AM, Sergio Correia <lists@uece.net> wrote:
> > So far it has happened only once.
> > Last commit is 471368557a734c6c486ee757952c902b36e7fd01.
> >
> >
> > [ 3726.624387] ------------[ cut here ]------------
> > [ 3726.624398] WARNING: at net/ipv4/tcp.c:1301 tcp_cleanup_rbuf+0x4f/0x110()
> > [ 3726.624400] Hardware name: N53SV
> > [ 3726.624402] cleanup rbuf bug: copied A4D1F126 seq A4D1F126 rcvnxt A4D1F126
> > [ 3726.624404] Modules linked in:
> > [ 3726.624407] Pid: 1416, comm: transmission-gt Not tainted 3.4.0-git+ #52
> > [ 3726.624409] Call Trace:
> > [ 3726.624415]  [<ffffffff81035eba>] warn_slowpath_common+0x7a/0xb0
> > [ 3726.624419]  [<ffffffff81035f91>] warn_slowpath_fmt+0x41/0x50
> > [ 3726.624507]  [<ffffffff81aa57a5>] ? sub_preempt_count+0x65/0xc0
> > [ 3726.624510]  [<ffffffff819101cf>] tcp_cleanup_rbuf+0x4f/0x110
> > [ 3726.624514]  [<ffffffff819112b7>] tcp_recvmsg+0x637/0xa60
> > [ 3726.624518]  [<ffffffff81849310>] ? release_sock+0xe0/0x110
> > [ 3726.624522]  [<ffffffff81934a34>] inet_recvmsg+0x94/0xc0
> > [ 3726.624534]  [<ffffffff81844792>] sock_aio_read.part.8+0x142/0x170
> > [ 3726.624537]  [<ffffffff818447c0>] ? sock_aio_read.part.8+0x170/0x170
> > [ 3726.624540]  [<ffffffff818447e1>] sock_aio_read+0x21/0x30
> > [ 3726.624544]  [<ffffffff81124b0a>] do_sync_readv_writev+0xca/0x110
> > [ 3726.624548]  [<ffffffff8140f582>] ? security_file_permission+0x92/0xb0
> > [ 3726.624552]  [<ffffffff8112425c>] ? rw_verify_area+0x5c/0xe0
> > [ 3726.624555]  [<ffffffff81124de6>] do_readv_writev+0xd6/0x1e0
> > [ 3726.624558]  [<ffffffff8184336b>] ? sock_do_ioctl+0x2b/0x70
> > [ 3726.624562]  [<ffffffff81135abf>] ? do_vfs_ioctl+0x8f/0x530
> > [ 3726.624566]  [<ffffffff8141278f>] ? file_has_perm+0x8f/0xa0
> > [ 3726.624569]  [<ffffffff81124f7d>] vfs_readv+0x2d/0x50
> > [ 3726.624572]  [<ffffffff81124fe5>] sys_readv+0x45/0xb0
> > [ 3726.624575]  [<ffffffff81aa9062>] system_call_fastpath+0x16/0x1b
> > [ 3726.624578] ---[ end trace 6dc5d813929e5e6f ]---
> 
> Checked this morning, and my dmesg now is basically composed of this
> warning over and over and over.

Is it wifi adapter ?

Please send "netstat -s" output
