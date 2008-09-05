From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: latest git crash (BUG/rt_fill_info)
Date: Fri, 5 Sep 2008 11:36:24 +0000
Message-ID: <20080905113623.GB7320@ff.dom.local>
References: <200809041751.04163.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.239]:14466 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbYIELgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 07:36:31 -0400
Received: by wr-out-0506.google.com with SMTP id 69so379156wri.5
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2008 04:36:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200809041751.04163.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04-09-2008 16:51, Denys Fedoryshchenko wrote:
> Single processor, working as NAT at office.
> I will try to reproduce the bug. Crash is happening on "light" traffic, after 10-20 minutes of usage.
> 
> Sep  4 17:43:41 x.x.x.x [ 1084.917877] BUG: unable to handle kernel 
> Sep  4 17:43:41 x.x.x.x paging request
> Sep  4 17:43:41 x.x.x.x at 84e8dc55
> Sep  4 17:43:41 x.x.x.x [ 1084.917943] IP:
> Sep  4 17:43:41 x.x.x.x [<c02826be>] rt_fill_info+0x329/0x33f

I guess it would be helpful to put vmlinux from this kernel build
under some link (or send some gdb listing of this address).

Jarek P.
