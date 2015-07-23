From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC Patch net-next] inet: introduce a sysctl
 ip_local_ports_strict_use
Date: Wed, 22 Jul 2015 22:39:04 -0700
Message-ID: <20150722223904.20ef9011@uryu.home.lan>
References: <1437610057-13197-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, davem@davemloft.net
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34916 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbbGWFjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 01:39:08 -0400
Received: by pabkd10 with SMTP id kd10so79396203pab.2
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 22:39:07 -0700 (PDT)
In-Reply-To: <1437610057-13197-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Jul 2015 17:07:37 -0700
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> For a real example, named randomly selects some port to bind() for
> security concern. (It doesn't use bind(0) to let kernel to select port
> because it is not random enough, kernel usually just picks the next
> available.) When running named on a Mesos controlled host, named would
> silently fail when it binds a port assigned to a Mesos container.

I think named is trying to workaround security issues that were fixed
5 years ago in Linux. The kernel does not just pick the next available
in current code.
