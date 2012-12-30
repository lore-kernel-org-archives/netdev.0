From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net-next] team: update master carrier state
Date: Sun, 30 Dec 2012 20:06:16 -0200
Message-ID: <20121230220616.GA2065@obelix.rh>
References: <1356892049-14667-1-git-send-email-fbl@redhat.com>
 <20121230214723.GD1575@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39681 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753046Ab2L3WGU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Dec 2012 17:06:20 -0500
Content-Disposition: inline
In-Reply-To: <20121230214723.GD1575@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 30, 2012 at 10:47:23PM +0100, Jiri Pirko wrote:
> Sun, Dec 30, 2012 at 07:27:29PM CET, fbl@redhat.com wrote:
> >Update master's carrier state when there is any
> >change with its ports.
> 
> 
> This patch looks good to me. Just one nitpick I spotted....
> 
> >+	bool team_linkup;
> >+
> >+	team_linkup = false;
> 
> 
> This can be squashed together.

Ok, but that increases the static size of the module because it
moves the variable out of bss.

I have no strong opinion on either case, so it's up to you.

Thanks,
-- 
fbl
