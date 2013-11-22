From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: dynamic TCP algorithms switching
Date: Fri, 22 Nov 2013 15:53:03 -0800
Message-ID: <20131122155303.68da12ec@nehalam.linuxnetplumber.net>
References: <CAAVq3rnxE92PsJOChr+H52k5QfG7E=hAjsohK4Um0ZRO9TdYuA@mail.gmail.com>
	<20131122145621.344fa999@nehalam.linuxnetplumber.net>
	<CAAVq3rnmWUAzDGy9_nMLsbx++opgZpuYtG34VpZEBbJ2psBnZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
To: yan cui <ccuiyyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:54642 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756344Ab3KVXxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 18:53:07 -0500
Received: by mail-pb0-f44.google.com with SMTP id rq2so1982674pbb.17
        for <netdev@vger.kernel.org>; Fri, 22 Nov 2013 15:53:07 -0800 (PST)
In-Reply-To: <CAAVq3rnmWUAzDGy9_nMLsbx++opgZpuYtG34VpZEBbJ2psBnZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Nov 2013 18:21:12 -0500
yan cui <ccuiyyan@gmail.com> wrote:

> Then, why include so many (current Linux has 10+ TCP congestion algorithms)
> algorithms? For users who want to deploy their application on Linux
> and if the applications
> are system resource intensive, they always want to tune the
> configurations of the operating systems for the last piece of
> performance. If they do so, maybe they are confused
> about which TCP congestion algorithm to use for their environment. So,
> the only way is to try each algorithm one by one. I understand the
> setting of the default TCP congestion
> algorithm to be Cubic means that it works well for most environments.
> But if others
> are seldom used, or can be replace with another implementation.
> Why not just remove from the kernel?
> 
> Yan

Most are intended for research and testing only.
Only a few are worth considering in a production environment.
That is also why there so many qdisc algorithms as well.
