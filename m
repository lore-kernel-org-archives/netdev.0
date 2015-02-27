From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 v4] lib: Replace 16384 netlink buf size by macro
Date: Fri, 27 Feb 2015 19:47:31 +0200
Message-ID: <20150227174731.GA6949@angus-think.wlc.globallogic.com>
References: <1425018700-32725-1-git-send-email-vadim4j@gmail.com>
 <20150227.123831.436431838595846209.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vadim4j@gmail.com, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:36727 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158AbbB0R64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 12:58:56 -0500
Received: by lbvp9 with SMTP id p9so18914708lbv.3
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 09:58:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150227.123831.436431838595846209.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2015 at 12:38:31PM -0500, David Miller wrote:
> From: Vadim Kochan <vadim4j@gmail.com>
> Date: Fri, 27 Feb 2015 08:31:40 +0200
> 
> > From: Vadim Kochan <vadim4j@gmail.com>
> > 
> > Replaced hard coded 16384 netlink buffer size by NLBUF_SIZE,
> > which can be overridden by -DNLBUF_SIZE.
> > 
> > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> 
> I would like to know what problem is solved by changing this to
> any other value?
> 
> And then I would like to know why other potential solutions to
> this problem were not considered, such as making the buffer size
> dynamic and run-time selectable, perhaps with a size choosen
> in a manner to avoid whatever problem you hit with the current
> size.

Its just for the case when it might be changed in the future then it can be
easy found and changed. Just reject it if it looks useless. About
dynamic changing I think it makes sense to do it because memset is used
on the each netlink 16384 sized msg.
