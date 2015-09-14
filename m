From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH] net: sched: document attach_default_qdiscs
Date: Mon, 14 Sep 2015 15:49:30 -0700
Message-ID: <CAHA+R7NoiTHoxaf+FhPo01evDd_W4g_Oz7o-CuoewFdHU_g3hA@mail.gmail.com>
References: <1442244690-6672-1-git-send-email-phil@nwl.cc>
	<CAHA+R7PATvda=EPof5mHY_CNH1OnkVnRytJPbJgZHtTkgMB9LA@mail.gmail.com>
	<20150914224208.GJ30501@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:35460 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622AbbINWta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 18:49:30 -0400
Received: by ykdu9 with SMTP id u9so168883894ykd.2
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2015 15:49:30 -0700 (PDT)
In-Reply-To: <20150914224208.GJ30501@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 14, 2015 at 3:42 PM, Phil Sutter <phil@nwl.cc> wrote:
> On Mon, Sep 14, 2015 at 03:07:42PM -0700, Cong Wang wrote:
>> Maybe update default_qdisc description in Documentation/sysctl/net.txt?
>
> I don't think this is the right place for source code documentation. The
> intended audience are users, and I wouldn't expect a developer to search
> in there. On the other hand, that description would indeed benefit from
> a review: Apart from omitting noqueue, it neither mentions leaf qdiscs.
> I'll fix this.
>

You are not just documenting the source code, you are documenting
a user-visible behavior. This is why I proposed net.txt.
