From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 1/2] fib6: install fib6 ops in the last step
Date: Wed, 25 Mar 2015 20:49:55 -0700
Message-ID: <CAM_iQpUPhS2kMCvdZGXm+5ahXV15tcj0bQRcZ0JNMuyAYzfjrg@mail.gmail.com>
References: <1427319903-22976-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34076 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbbCZDtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 23:49:55 -0400
Received: by pacwe9 with SMTP id we9so50081657pac.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 20:49:55 -0700 (PDT)
In-Reply-To: <1427319903-22976-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2015 at 2:45 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> We should not commit the new ops until we finish
> all the setup, otherwise we have to NULL it on failure.
>

I messed up my net branch with net-next, so this single patch
actually doesn't fix any bug so can be just targeted for net-next.

Let me know if you want me to resend.
