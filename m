From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v3 0/3] improve lwtunnel route support
Date: Fri, 18 Dec 2015 11:43:24 -0800
Message-ID: <20151218114324.007fe1b8@xeon-e3>
References: <cover.1450428323.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jiri Benc <jbenc@redhat.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34192 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932554AbbLRTnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 14:43:35 -0500
Received: by mail-pa0-f52.google.com with SMTP id wq6so65064015pac.1
        for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 11:43:34 -0800 (PST)
In-Reply-To: <cover.1450428323.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Dec 2015 10:50:35 +0100
Paolo Abeni <pabeni@redhat.com> wrote:

> This patch series try to improve the current route based
> lwtunnel support in iproute2, namely adding support for the
> COLLECT_METADATA flag in vxlan and gre link, and for ip6
> encap type in lwtunnel.
> 
> Tunnel devices need to have the COLLECT_METADATA flag
> set in order to be used for route based lwtunnel.
> 
> Changes from V1:
> - the COLLECT_METADATA flag is now controlled via the 'external' keyword
> - 'vni' and 'external' arguments are mutually exclusive for the vxlan link
> 
> Changes from V2:
> - rebased
> 
> Paolo Abeni (3):
>   vxlan: add support for collect metadata flag
>   gre: add support for collect metadata flag
>   lwtunnel: implement support for ip6 encap
> 
>  ip/iplink_vxlan.c     | 19 +++++++++--
>  ip/iproute_lwtunnel.c | 92 ++++++++++++++++++++++++++++++++++++++++++++++++++-
>  ip/link_gre.c         | 11 ++++++
>  3 files changed, 119 insertions(+), 3 deletions(-)
> 

Applied thanks.
