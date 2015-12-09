From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Checksum offload queries
Date: Wed, 9 Dec 2015 23:44:45 +0100
Message-ID: <20151209224445.GI11201@pox.localdomain>
References: <5665A848.9010001@solarflare.com>
 <20151207.143848.2158761076110518741.davem@davemloft.net>
 <5666EC4B.40800@solarflare.com>
 <20151208.120654.2127200076257822677.davem@davemloft.net>
 <56681B18.3030200@solarflare.com>
 <CALx6S357W+HXp4S8+tveKrqJ3-2XrZsKmBTvxZVHdwF93UWkOw@mail.gmail.com>
 <566864C0.6020204@solarflare.com>
 <CALx6S34+j0xQk7gfwOa9adBc3fkjhTJG366eDcT81AzKnWCrLA@mail.gmail.com>
 <20151209222153.GE11201@pox.localdomain>
 <CALx6S34pkU6XYk4N8MRszae-GoZRzK4vct=WpcX_KC-O9J8p0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36603 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835AbbLIWor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 17:44:47 -0500
Received: by mail-wm0-f47.google.com with SMTP id w144so1213538wmw.1
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 14:44:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALx6S34pkU6XYk4N8MRszae-GoZRzK4vct=WpcX_KC-O9J8p0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/15 at 02:42pm, Tom Herbert wrote:
> csum_start and csum_offset together occupy 32 bits. As demonstrated in
> VXLAN RCO we can compress csum_start/csum_offset down to 8 bits which
> means if necessary we could get up to four pairs in an sk_buff without
> increasing its size. If you need more that four checksums to be
> offloaded in single packet then I doubt getting checksum offload to
> work is going to be your biggest problem.

Fair point. I wouldn't suggest even creating it without huge demand
first. There should be as many incentives as possible to move or stay
away from such horrible architectures.
