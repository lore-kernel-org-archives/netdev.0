From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Intel igb module command line configuration in kernel sources
Date: Thu, 5 Sep 2013 15:23:59 +0100
Message-ID: <1378391039.3159.1.camel@bwh-desktop.uk.level5networks.com>
References: <CAJLXCZRKdz-w8uR3ejzHrBot7OAyVJOWwzA0NszkZL16eFPTbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Andrew Davidoff <davidoff@qedmf.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17135 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704Ab3IERne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 13:43:34 -0400
In-Reply-To: <CAJLXCZRKdz-w8uR3ejzHrBot7OAyVJOWwzA0NszkZL16eFPTbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-04 at 22:51 -0400, Andrew Davidoff wrote:
> Hi,
> 
> I apologize that this is a user-type question but linux-net seems to
> have gone away, and I cannot find a more appropriate networking
> related mailing list.
> 
> Why are the Intel igb module configuration parameters, usually found
> in igb_param.c and part of the source from Intel, not included in the
> igb sources distributed with the linux kernel? I cannot find them in
> the kernel's igb source, modinfo doesn't list them, and if I try to
> use them as documented in the igb readme, I get errors because they
> are unrecognized (ex: RSS). Am I overlooking an alternate
> configuration method?

I don't know what you're specifically interested in, but a lot of this
should be configurable using ethtool.

Module parameters for device-specific settings are deprecated.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
