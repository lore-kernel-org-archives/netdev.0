From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH] net: sched: document attach_default_qdiscs
Date: Mon, 14 Sep 2015 15:07:42 -0700
Message-ID: <CAHA+R7PATvda=EPof5mHY_CNH1OnkVnRytJPbJgZHtTkgMB9LA@mail.gmail.com>
References: <1442244690-6672-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:33968 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbbINWHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 18:07:42 -0400
Received: by ykdg206 with SMTP id g206so167128363ykd.1
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2015 15:07:42 -0700 (PDT)
In-Reply-To: <1442244690-6672-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 14, 2015 at 8:31 AM, Phil Sutter <phil@nwl.cc> wrote:
> The process of selecting an interface's default qdisc is not really
> intuitive, at least because there are three different cases to consider.

It is a static function, not an API, so I don't think it is the right
place to document.

Maybe update default_qdisc description in Documentation/sysctl/net.txt?
