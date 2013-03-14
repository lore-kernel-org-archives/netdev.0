From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH iproute2 0/2] Add support for bridge port link information
Date: Thu, 14 Mar 2013 14:49:01 -0400
Message-ID: <51421B9D.8000108@redhat.com>
References: <1363206994-18599-1-git-send-email-vyasevic@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57247 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752357Ab3CNStE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Mar 2013 14:49:04 -0400
In-Reply-To: <1363206994-18599-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2013 04:36 PM, Vlad Yasevich wrote:
> Bridge ports provide unique link information about the properties and flags of
> the port.  This patch set allows bridge utility to configure and disaplay
> this information.
>
> Vlad Yasevich (2):
>    bridge: Add support for setting bridge port attributes
>    bridge: Add support for printing bridge port attributes
>
>   bridge/br_common.h   |    1 +
>   bridge/bridge.c      |    3 +-
>   bridge/link.c        |  289 ++++++++++++++++++++++++++++++++++++++++++++++++-
>   include/libnetlink.h |    2 +
>   lib/libnetlink.c     |   13 ++-
>   5 files changed, 299 insertions(+), 9 deletions(-)
>

Oh, forgot to write the doc patch.  I'll write that up and update the
series.

-vlad
