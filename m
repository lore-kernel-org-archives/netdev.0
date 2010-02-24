From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [RFC PATCH net-next 1/5]IPv6:netfilter: defrag:Introduce net
	namespace
Date: Wed, 24 Feb 2010 09:48:38 +0200
Message-ID: <b6fcc0a1002232348y6ff84ca8wf3bdf21de45fffbd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f177.google.com ([209.85.223.177]:34911 "EHLO
	mail-iw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755513Ab0BXHsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 02:48:38 -0500
Received: by iwn7 with SMTP id 7so3946629iwn.4
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2010 23:48:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -		.procname	= "nf_conntrack_frag6_timeout",
> -		.data		= &nf_init_frags.timeout,
> -		.maxlen		= sizeof(unsigned int),
> -		.mode		= 0644,
> -		.proc_handler	= proc_dointvec_jiffies,

Why are you removing sysctls?
