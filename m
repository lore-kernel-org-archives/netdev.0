From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 0/6] net: vlan: add support for 802.1ad
Date: Fri, 19 Apr 2013 08:25:41 -0700
Message-ID: <20130419082541.5391d175@nehalam.linuxnetplumber.net>
References: <1366373072-19621-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:50253 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030512Ab3DSP0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 11:26:13 -0400
Received: by mail-pa0-f45.google.com with SMTP id kl13so2337044pab.18
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 08:26:13 -0700 (PDT)
In-Reply-To: <1366373072-19621-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Apr 2013 14:04:26 +0200
Patrick McHardy <kaber@trash.net> wrote:

> The following patches add support for 802.1ad (provider tagging) to the
> VLAN driver. The patchset consists of the following parts:
> 
> - renaming of the NET_F_HW_VLAN feature flags to indicate that they only
>   operate on CTAGs
> 
> - preparation for 802.1ad VLAN filtering offload by adding a proto argument
>   to the rx_{add,kill}_vid net_device_ops callbacks
> 
> - preparation of the VLAN code to support multiple protocols by making the
>   protocol used for tagging a property of the VLAN device and converting
>   the device lookup functions accordingly
> 
> - second step of preparation of the VLAN code by making the packet tagging
>   functions take a protocol argument
> 
> - introducation of 802.1ad support in the VLAN code, consisting mainly of
>   checking for ETH_P_8021AD in a couple of places and testing the netdevice
>   offload feature checks to take the protocol into account
> 
> - announcement of STAG offloading capabilities in a couple of drivers for
>   virtual network devices
> 
> The patchset is based on net-next.git and has been tested with single and
> double tagging with and without HW acceleration (for CTAGs).
> 
> If there are no objections, please apply. Thanks!

Glad to see this, there have been requests to fix the current broken QinQ in Linux.

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
