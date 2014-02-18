From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next] rtnl: make ifla_policy static
Date: Tue, 18 Feb 2014 13:40:55 -0800
Message-ID: <CAM_iQpUzp7xkj21dyzzXRjZgyO+z5+k4cDM9LoYkzy4OL8807w@mail.gmail.com>
References: <1392753198-9437-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	vyasevic@redhat.com, jbenc@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:35837 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbaBRVk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 16:40:56 -0500
Received: by mail-oa0-f53.google.com with SMTP id m1so19989449oag.40
        for <netdev@vger.kernel.org>; Tue, 18 Feb 2014 13:40:55 -0800 (PST)
In-Reply-To: <1392753198-9437-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 18, 2014 at 11:53 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> The only place this is used outside rtnetlink.c is veth. So provide
> wrapper function for this usage.

Looks good. Or make rtnl_nla_parse_ifla() static inline?
