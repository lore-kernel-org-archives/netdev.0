From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] tunnels: Don't require remote endpoint or ID during
 creation.
Date: Sat, 17 Oct 2015 09:45:31 +0200
Message-ID: <20151017074531.GA13981@pox.localdomain>
References: <1445038560-85471-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	John Linville <linville@tuxdriver.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:37012 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbbJQHpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 03:45:34 -0400
Received: by wicfv8 with SMTP id fv8so17237089wic.0
        for <netdev@vger.kernel.org>; Sat, 17 Oct 2015 00:45:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445038560-85471-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/15 at 04:36pm, Jesse Gross wrote:
> Before lightweight tunnels existed, it really didn't make sense to
> create a tunnel that was not fully specified, such as without a
> destination IP address - the resulting packets would go nowhere.
> However, with lightweight tunnels, the opposite is true - it doesn't
> make sense to require this information when it will be provided later
> on by the route. This loosens the requirements for this information.
> 
> An alternative would be to allow the relaxed version only when
> COLLECT_METADATA is enabled. However, since there are several
> variations on this theme (such as NBMA tunnels in GRE), just dropping
> the restrictions seems the most consistent across tunnels and with
> the existing configuration.
> 
> CC: John Linville <linville@tuxdriver.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

I left it like it was for VXLAN with the thought that you had
specifically enable the metadata driven TX but I'm perfectly
fine with this as well.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
