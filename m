From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: sfc userland MCDI - request for guidance
Date: Sat, 16 Jan 2016 11:03:09 +0100
Message-ID: <20160116100309.GB2129@nanopsycho.orion>
References: <56992D8C.7090003@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34438 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbcAPKDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jan 2016 05:03:12 -0500
Received: by mail-wm0-f67.google.com with SMTP id b14so7054079wmb.1
        for <netdev@vger.kernel.org>; Sat, 16 Jan 2016 02:03:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56992D8C.7090003@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jan 15, 2016 at 06:34:04PM CET, ecree@solarflare.com wrote:
>I have a design problem with a few possible solutions and I'd like some
> guidance on which ones would be likely to be acceptable.
>
>The sfc driver communicates with the hardware using a protocol called MCDI -
> Management Controller to Driver Interface - and for various reasons
> (ranging from test automation to configuration utilities) we would like to
> be able to do this from userspace.  We currently have two ways of handling
> this, neither of which is satisfactory.

It is wrong to send commands to HW directly to userspace. Please, do
proper in-kernel vendor neutral feature abstraction and the implement
in your driver. That is how things work. Userspace->HW bypass
is simply unacceptable.
