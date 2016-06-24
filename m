From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 0/6] Add support for vrf keyword
Date: Thu, 23 Jun 2016 19:46:02 -0600
Message-ID: <074b0f4f-7d76-7f03-79b1-c1b1f0a40303@cumulusnetworks.com>
References: <1465937972-25011-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:32852 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847AbcFXBqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 21:46:06 -0400
Received: by mail-pf0-f171.google.com with SMTP id i123so34015567pfg.0
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 18:46:05 -0700 (PDT)
In-Reply-To: <1465937972-25011-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/14/16 2:59 PM, David Ahern wrote:
> Currently the syntax for VRF related commands is rather kludgy and
> inconsistent from one subcommand to another. This set adds support
> for the VRF keyword to the link, address, neigh, and route commands
> to improve the user experience listing data associated with vrfs,
> modifying routes or doing a route lookup.
>
> David Ahern (6):
>   ip vrf: Add name_is_vrf
>   ip link/addr: Add support for vrf keyword
>   ip neigh: Add support for keyword
>   ip route: Change type mask to bitmask
>   ip vrf: Add ipvrf_get_table
>   ip route: Add support for vrf keyword
>
>  ip/ip_common.h  |   3 ++
>  ip/ipaddress.c  |  11 ++++++
>  ip/iplink.c     |  15 ++++++-
>  ip/iplink_vrf.c | 119 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  ip/ipneigh.c    |  14 ++++++-
>  ip/iproute.c    |  43 ++++++++++++++++----
>  6 files changed, 195 insertions(+), 10 deletions(-)
>

Stephen: This patchset is marked 'Changes Requested' in patchworks, yet 
I have not seen any responses to them. What change was requested?

David
