From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] team: send port changed when added
Date: Sat, 22 Sep 2012 19:04:54 +0200
Message-ID: <20120922170454.GA2472@minipsycho.orion>
References: <1348228319-11453-1-git-send-email-jiri@resnulli.us>
 <20120921.150142.1121078984466626799.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:48351 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980Ab2IVRFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 13:05:00 -0400
Received: by wgbdr13 with SMTP id dr13so2336627wgb.1
        for <netdev@vger.kernel.org>; Sat, 22 Sep 2012 10:04:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120921.150142.1121078984466626799.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 21, 2012 at 09:01:42PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Fri, 21 Sep 2012 13:51:59 +0200
>
>> On some hw, link is not up during adding iface to team. That causes event
>> not being sent to userspace and that may cause confusion.
>> Fix this bug by sending port changed event once it's added to team.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>Applied, thanks a lot Jiri.

David, I just realized this would be good to have fixed in net tree as
well. Unfortunately this patch does not apply cleanly. I will send you
backported patch for net tree in a jiffy.

Thanks!

Jiri
