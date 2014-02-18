From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] rtnl: make ifla_policy static
Date: Tue, 18 Feb 2014 22:51:28 +0100
Message-ID: <20140218215128.GA3348@minipsycho.orion>
References: <1392753198-9437-1-git-send-email-jiri@resnulli.us>
 <CAM_iQpUzp7xkj21dyzzXRjZgyO+z5+k4cDM9LoYkzy4OL8807w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	vyasevic@redhat.com, jbenc@redhat.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:63207 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054AbaBRVvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 16:51:32 -0500
Received: by mail-ee0-f42.google.com with SMTP id b15so8090366eek.29
        for <netdev@vger.kernel.org>; Tue, 18 Feb 2014 13:51:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAM_iQpUzp7xkj21dyzzXRjZgyO+z5+k4cDM9LoYkzy4OL8807w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 18, 2014 at 10:40:55PM CET, xiyou.wangcong@gmail.com wrote:
>On Tue, Feb 18, 2014 at 11:53 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> The only place this is used outside rtnetlink.c is veth. So provide
>> wrapper function for this usage.
>
>Looks good. Or make rtnl_nla_parse_ifla() static inline?

Not possible if we want to kill ifla_policy export...
