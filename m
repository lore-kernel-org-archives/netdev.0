From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/4] vxlan: add VXLAN-GPE support
Date: Mon, 11 Apr 2016 15:17:54 -0700
Message-ID: <20160411151754.6613c2f1@xeon-e3>
References: <cover.1460032274.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34231 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754539AbcDKWRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 18:17:44 -0400
Received: by mail-pa0-f43.google.com with SMTP id ot11so97838pab.1
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 15:17:43 -0700 (PDT)
In-Reply-To: <cover.1460032274.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  7 Apr 2016 14:36:25 +0200
Jiri Benc <jbenc@redhat.com> wrote:

> This patchset adds a couple of refinements to the 'external' keyword and
> adds support for configuring VXLAN-GPE interfaces.
> 
> The VXLAN-GPE support was recently merged to net-next.
> 
> The first patch is not intended to be applied directly but I still include
> it in order for this patchset to be compilable and testable by those
> interested.
> 
> Jiri Benc (4):
>   if_link.h: rebase to the kernel
>   vxlan: 'external' implies 'nolearning'
>   ip-link.8: document "external" flag for vxlan
>   vxlan: add support for VXLAN-GPE
> 
>  include/linux/if_link.h |  1 +
>  ip/iplink_vxlan.c       | 14 ++++++++++++--
>  man/man8/ip-link.8.in   | 17 +++++++++++++++++
>  3 files changed, 30 insertions(+), 2 deletions(-)
> 

Applied to net-next
