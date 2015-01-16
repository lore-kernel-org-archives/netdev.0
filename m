From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH] net: rocker: Add basic netdev counters - v2
Date: Fri, 16 Jan 2015 16:48:59 -0700
Message-ID: <54B9A36B.1050204@gmail.com>
References: <1421443349-77718-1-git-send-email-dsahern@gmail.com> <CAE4R7bA3QG4LDvVQywDsRuJzJYv4mBq3=OXi2L=qGDfa4a8ykw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:61806 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbbAPXtC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 18:49:02 -0500
Received: by mail-pd0-f172.google.com with SMTP id v10so4106816pde.3
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 15:49:01 -0800 (PST)
In-Reply-To: <CAE4R7bA3QG4LDvVQywDsRuJzJYv4mBq3=OXi2L=qGDfa4a8ykw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/16/15 4:41 PM, Scott Feldman wrote:
>
> Thanks David.  I think this is good enough for first pass.  Longer
> term, I'd like to see this replaced by stats read from device for each
> port.

Aren't there 2 sets of stats at play here?
1. packets punted to the control plane / CPU,
2. packets forwarded through the ports.

If you have the netdev counters resemble packets handled through the 
port it could be confusing to someone looking at packets handled by the OS.

What about having detailed counters local to the driver (i.e., ethtool 
-S) show the low level stats like packets handled through the port?

David
