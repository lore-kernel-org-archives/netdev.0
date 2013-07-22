From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [patch net-next v3 1/3] net: add ndo to get id of physical port
 of the device
Date: Mon, 22 Jul 2013 18:59:37 +0300
Message-ID: <CAJZOPZ+tbr8qvCJ7wDbXUhOEh4Q6j-_J1CFzFkb8nm4e3AwSrA@mail.gmail.com>
References: <1374498317-6442-1-git-send-email-jiri@resnulli.us>
	<1374498317-6442-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, Narendra_K@dell.com,
	bhutchings@solarflare.com, john.r.fastabend@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:60342 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757618Ab3GVP7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 11:59:38 -0400
Received: by mail-qa0-f53.google.com with SMTP id hu14so695507qab.19
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 08:59:37 -0700 (PDT)
In-Reply-To: <1374498317-6442-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 22, 2013 at 4:05 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> This patch adds a ndo for getting physical port of the device. Driver
> which is aware of being virtual function of some physical port should
> implement this ndo. This is applicable not only for IOV, but for other
> solutions (NPAR, multichannel) as well. Basically if there is possible
> to have multiple netdevs on the single hw port.

BTW - one thing which can be helpful for the discussion, is to have
this new ndo actually implemented for a certain driver. Also typically
we prefer to avoid adding new features at the networking core layer
without any concrete user. Making some driver to implement a new
feature is always a good way to see it flies well.

Or.

>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Acked-by: Ben Hutchings <bhutchings@solarflare.com>
