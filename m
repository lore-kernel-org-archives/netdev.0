From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] switchdev: don't abort hardware ipv4 fib
 offload on failure to program fib entry in hardware
Date: Mon, 18 May 2015 23:48:39 -0400 (EDT)
Message-ID: <20150518.234839.995695850653714769.davem@davemloft.net>
References: <1431906125-13808-1-git-send-email-roopa@cumulusnetworks.com>
	<20150518.161916.2132217836491222672.davem@davemloft.net>
	<555A8209.5000306@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34884 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbbESDsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 23:48:43 -0400
In-Reply-To: <555A8209.5000306@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Mon, 18 May 2015 17:21:29 -0700

> So how about having an error strategy sysctl field that we can set
> at provisioning time. I think this would align to Roopa's option (b).
> This way we can default to "transparent" mode and the users where
> this wont work can set the error mode. This way user land software
> stacks that work today should continue to work in both modes.

Alert: This is not a switch provisioning issue.

You can frame it like that all day, and continue to talk about
low power cpus or other things which are completely and utterly
irrelevant.

Stop looking at how some specific piece of hardware is configured,
and think about what actually is asking the kernel to do stuff.

That's because the real issue is _semantics_ and what a Linux machine
is expected to do when you insert a route and valid reasons why a
route insertion can fail.

That is the _only_ issue.

And that has to do with what semantics _applcations_ making these
routing change requests expect.

There is nothing else that matters.

And since it is an issue of what semantics those application want and
are able to handle, that is where the request of changed behavior
belongs.

If we added your suggested sysctl, we'd have to name it
"sysctl_break_all_my_apps_please" because that is exactly what it
would be doing. :-)
