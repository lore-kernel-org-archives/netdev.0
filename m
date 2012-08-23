From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH bridge 4/5] bridge: Add private ioctls to configure
 vlans on bridge ports
Date: Thu, 23 Aug 2012 12:38:09 -0700
Message-ID: <20120823123809.1a4adfbe@nehalam.linuxnetplumber.net>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
	<1345750195-31598-5-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40925 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932370Ab2HWTi1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 15:38:27 -0400
In-Reply-To: <1345750195-31598-5-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Aug 2012 15:29:54 -0400
Vlad Yasevich <vyasevic@redhat.com> wrote:

> Add a private ioctl to add and remove vlan configuration on bridge port.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  include/linux/if_bridge.h |    2 +
>  net/bridge/br_if.c        |   69 +++++++++++++++++++++++++++++++++++++++++++++
>  net/bridge/br_ioctl.c     |   31 ++++++++++++++++++++
>  net/bridge/br_private.h   |    2 +
>  4 files changed, 104 insertions(+), 0 deletions(-)


Don't go down this dead end.

The ioctl interface to bridge is deprecated because private ioctl's
can not be handled when running 32 bit user space on 64 bit kernel.
