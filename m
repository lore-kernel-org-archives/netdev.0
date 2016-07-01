From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] bridge: vlan: add support to display
 per-vlan statistics
Date: Thu, 30 Jun 2016 17:06:59 -0700
Message-ID: <20160630170659.07f46c3c@xeon-e3>
References: <1466417599-12940-1-git-send-email-nikolay@cumulusnetworks.com>
	<20160621090141.0c13d12d@xeon-e3>
	<57696709.7010506@cumulusnetworks.com>
	<5769674F.3090700@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34788 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052AbcGAAGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 20:06:46 -0400
Received: by mail-pa0-f53.google.com with SMTP id bz2so32877800pad.1
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 17:06:45 -0700 (PDT)
In-Reply-To: <5769674F.3090700@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jun 2016 18:11:59 +0200
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> >> Thanks, this is a useful tool, but I think the formatting of output may need to be
> >> reworked.  The bridge tool works similar to ip command. And in the ip command the
> >> -s flag causes additional lines, but does not change the output format.  
> > 
> > Indeed, I agree that it needs refinement.
> >   
> 
> Or alternatively I can make it:
> $ bridge vlan stats
> a subcommand instead of using the "-s" argument in order to be consistent.
> So it can have its own format.

Why not:

$ bridge -s vlan show

to be consistent with:

$ ip -s li show
