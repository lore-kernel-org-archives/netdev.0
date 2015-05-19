From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net v2] switchdev: don't abort hardware ipv4 fib offload
 on failure to program fib entry in hardware
Date: Tue, 19 May 2015 19:01:22 +0200
Message-ID: <20150519170122.GD2124@nanopsycho.orion>
References: <555A8209.5000306@intel.com>
 <20150518.234839.995695850653714769.davem@davemloft.net>
 <555AD11E.5040709@cumulusnetworks.com>
 <20150519.123418.481170679256206928.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa@cumulusnetworks.com, john.r.fastabend@intel.com,
	sfeldma@gmail.com, john.fastabend@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:34506 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100AbbESRB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 13:01:26 -0400
Received: by wghq2 with SMTP id q2so25249026wgh.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 10:01:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150519.123418.481170679256206928.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 19, 2015 at 06:34:18PM CEST, davem@davemloft.net wrote:
>From: roopa <roopa@cumulusnetworks.com>
>Date: Mon, 18 May 2015 22:58:54 -0700
>
>> from where I see, with the limitations on these boxes, this requires
>> every app, every `ip route` cmd running on the box to explicitly
>> specify offload when running on this hardware.
>
>Users know what they are doing, and will ask for a policy change.
>
>The default should be what happens right now.

I agree.
