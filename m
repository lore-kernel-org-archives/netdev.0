From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 1/3] net: add ndo to get id of physical port
 of the device
Date: Mon, 22 Jul 2013 20:01:41 +0200
Message-ID: <20130722180141.GA1498@minipsycho.orion>
References: <1374498317-6442-1-git-send-email-jiri@resnulli.us>
 <1374498317-6442-2-git-send-email-jiri@resnulli.us>
 <CAJZOPZ+tbr8qvCJ7wDbXUhOEh4Q6j-_J1CFzFkb8nm4e3AwSrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, Narendra_K@dell.com,
	bhutchings@solarflare.com, john.r.fastabend@intel.com
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f171.google.com ([209.85.215.171]:62030 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932561Ab3GVSBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 14:01:45 -0400
Received: by mail-ea0-f171.google.com with SMTP id m14so3991256eaj.2
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 11:01:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJZOPZ+tbr8qvCJ7wDbXUhOEh4Q6j-_J1CFzFkb8nm4e3AwSrA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 22, 2013 at 05:59:37PM CEST, or.gerlitz@gmail.com wrote:
>On Mon, Jul 22, 2013 at 4:05 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> This patch adds a ndo for getting physical port of the device. Driver
>> which is aware of being virtual function of some physical port should
>> implement this ndo. This is applicable not only for IOV, but for other
>> solutions (NPAR, multichannel) as well. Basically if there is possible
>> to have multiple netdevs on the single hw port.
>
>BTW - one thing which can be helpful for the discussion, is to have
>this new ndo actually implemented for a certain driver. Also typically
>we prefer to avoid adding new features at the networking core layer
>without any concrete user. Making some driver to implement a new
>feature is always a good way to see it flies well.

I have almost done implementation for igb/igbvf (consulting with Intel
guys) and I'm working on bnx2x NPAR as well (consulting with Broadcom). I will
post these patches soon.

After that, I plan to work on more drivers.

>
>Or.
>
>>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> Acked-by: Ben Hutchings <bhutchings@solarflare.com>
