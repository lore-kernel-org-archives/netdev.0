From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] ipip: advertise tunnel param via rtnl
Date: Fri, 09 Nov 2012 11:42:48 -0800
Message-ID: <1352490168.19779.776.camel@edumazet-glaptop>
References: <1352467239.19779.564.camel@edumazet-glaptop>
	 <1352477401-19044-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1352477401-19044-2-git-send-email-nicolas.dichtel@6wind.com>
	 <1352479020.19779.741.camel@edumazet-glaptop>  <509D36CB.9030509@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:55161 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753315Ab2KITmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 14:42:50 -0500
Received: by mail-pb0-f46.google.com with SMTP id rr4so3048037pbb.19
        for <netdev@vger.kernel.org>; Fri, 09 Nov 2012 11:42:50 -0800 (PST)
In-Reply-To: <509D36CB.9030509@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-09 at 18:00 +0100, Nicolas Dichtel wrote:

> If the principle is approved, yes. If we add it, we will have two
> ways to manage these tunnels, via netlink and via ioctl, is it ok?
> 
> A side effect could be to have an option or an argument to the module to not 
> create the control interface (tunl0, sit0, ...).

The principle is already used for gre tunnels, so it definitely is
approved ;)
