From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Getting IP address and port of a file descriptor
Date: Mon, 18 Jul 2016 13:14:26 -0700
Message-ID: <CAM_iQpXAA-W+1BCQ+evCt_-ENy-n4wsdvxaNSmNNih+F29+HWw@mail.gmail.com>
References: <CAMGYKAfWNm2d5n_3Tnxbwo2C1Ms+gNLp4C35BHmy-+Xwat0b+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Peter Chen <peter.feifan.chen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:33923 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbcGRUOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 16:14:46 -0400
Received: by mail-io0-f169.google.com with SMTP id q83so980931iod.1
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 13:14:46 -0700 (PDT)
In-Reply-To: <CAMGYKAfWNm2d5n_3Tnxbwo2C1Ms+gNLp4C35BHmy-+Xwat0b+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2016 at 12:09 PM, Peter Chen
<peter.feifan.chen@gmail.com> wrote:
> Hi,
>
>    I was wondering, if I was in the kernel, and I intercepted a system
> call such as read(). Would I be able, from the fd, determine the
> whether the fd is (1) a network socket? (2) the IP address and port of
> this socket? What are the kernel data structures and functions that
> can get these information for me in the kernel? Thanks.

You can use sockfd_lookup() to read the sock structure from a given fd,
after than you can call, for example, sock->ops->getname() to read
local IP address etc.
