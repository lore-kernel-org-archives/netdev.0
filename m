From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: qstats update in packet scheduling
Date: Mon, 24 Nov 2014 09:31:29 -0800
Message-ID: <1416850289.17888.67.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHmvzZQnBJbx3hfdvpXg0TZM-UooKxjM+-1HO6nSSpx4qJLcaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Josh Clark <jcinma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:51883 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753878AbaKXRbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 12:31:31 -0500
Received: by mail-ie0-f182.google.com with SMTP id x19so9416775ier.13
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 09:31:30 -0800 (PST)
In-Reply-To: <CAHmvzZQnBJbx3hfdvpXg0TZM-UooKxjM+-1HO6nSSpx4qJLcaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-24 at 12:06 -0500, Josh Clark wrote:
> Hi everyone,
> 
> I'm working on a research project to add some extra functionality to
> RED. Right now, I'm tracking qstats to look at the factors that RED
> uses to calculate marking probability. Using standard RED with printk
> debug statements, I'm seeing that there are some drops, but no change
> in qlen or backlog when I send 12Mbps through a 10Mbps link.
> 
> Does RED use some other means to update qstats and track backlog, or
> do I need to change how I'm sending the test traffic though?

With steady traffic, there is no reason qlen should vary.

It should reach some equilibrium as well.
