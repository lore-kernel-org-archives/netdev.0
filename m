From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: where is the ethernet device number determined?
Date: Thu, 12 May 2016 13:19:34 -0700
Message-ID: <CAM_iQpVmy4bAKB9jwd0+uetw6GZuxg4MOmOb4Zya31VUwRYDQQ@mail.gmail.com>
References: <5734E226.6040706@mail.usask.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Chris Friesen <cbf123@mail.usask.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:33851 "EHLO
	mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbcELUTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 16:19:54 -0400
Received: by mail-yw0-f169.google.com with SMTP id j74so84227090ywg.1
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 13:19:54 -0700 (PDT)
In-Reply-To: <5734E226.6040706@mail.usask.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 12, 2016 at 1:05 PM, Chris Friesen <cbf123@mail.usask.ca> wrote:
>
> Hi,
>
> I hope this is a simple question...with legacy naming ethernet devices are
> named ethX.  Where is that X determined?  I've been looking in
> alloc_netdev_mqs() and friends, but haven't found it yet.

__dev_alloc_name()
