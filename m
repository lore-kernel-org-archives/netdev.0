From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] net: clear iflink when moving to a new netns
Date: Thu, 13 Feb 2014 14:44:05 -0800
Message-ID: <CAHA+R7O4_a3wJct+rHhaQv+0OZHYV=c4+=QS9MTrQy5=rB1jLA@mail.gmail.com>
References: <1392162690-6647-1-git-send-email-xiyou.wangcong@gmail.com>
	<52FB969A.607@6wind.com>
	<CAHA+R7Pd07-3-ikK9=o=6ZhwT1PY6iZTmLUnCCsJ2-e=KS5jOA@mail.gmail.com>
	<87sirn4vqo.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:54613 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbaBMWoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:44:07 -0500
Received: by mail-lb0-f175.google.com with SMTP id p9so8626876lbv.6
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 14:44:05 -0800 (PST)
In-Reply-To: <87sirn4vqo.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 12, 2014 at 6:00 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> There was an effort not long ago to make tunnels safe to pass between
> namespaces.  NETIF_F_NETNS_LOCAL was removed from ip6_tunnel in that
> effort.  Apparently something was overlooked.
>
> Making iflink a netdevice reference or finding a way to remove it
> entirely seems better that masking the problem.
>

Yeah, looks like the trend is allowing more stacked devices to move to
a new netns.
Sounds good. I am working on a draft patch now.

Thanks.
