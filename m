From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net] rtnetlink: call rtnl_lock_unregistering() in
 rtnl_link_unregister()
Date: Fri, 9 May 2014 11:03:45 -0700
Message-ID: <20140509110345.417d2b90@nehalam.linuxnetplumber.net>
References: <1399657653-4909-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:40479 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262AbaEISDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 14:03:49 -0400
Received: by mail-pd0-f170.google.com with SMTP id v10so3999772pde.29
        for <netdev@vger.kernel.org>; Fri, 09 May 2014 11:03:49 -0700 (PDT)
In-Reply-To: <1399657653-4909-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  9 May 2014 10:47:33 -0700
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> I know making rtnl_lock_unregistering() a macro is ugly, but I don't find
> any less ugly way to fix it unless we duplicate the code. For long term,
> I think we should clean up the mess of netdev_run_todo() and net namespce
> exit code.

Huh, why isn't a real function going to work.
