From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH ethtool 0/7] Update RX n-tuple filtering
Date: Thu, 28 Oct 2010 18:02:12 -0400
Message-ID: <4CC9F2E4.4060408@pobox.com>
References: <1285278428.7794.27.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:37867 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758043Ab0J1WCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 18:02:16 -0400
Received: by iwn10 with SMTP id 10so2837078iwn.19
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 15:02:15 -0700 (PDT)
In-Reply-To: <1285278428.7794.27.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/23/2010 05:47 PM, Ben Hutchings wrote:
> This patch series brings ethtool up to date with my recent changes to RX
> n-tuple filtering in the kernel.
>
> Ben.
>
> Ben Hutchings (7):
>    ethtool-copy.h: sync with net-next
>    ethtool: Generalise cmdline_info::unwanted_val to a "seen" flag or
>      bitmask
>    ethtool: Fix RX n-tuple masks and documentation
>    ethtool: Add MAC parameter type based on the parse_sopass() function
>    ethtool: Add Ethernet-level RX n-tuple filtering and 'clear' action
>    ethtool: Update sfc register dump
>    ethtool: Add my authorship and Solarflare copyright notice
>
>   AUTHORS        |    1 +
>   ethtool-copy.h |  228 +++++++++++++++++++++++++++++++++---------------
>   ethtool.8      |   79 ++++++++++++-----
>   ethtool.c      |  265 +++++++++++++++++++++++++++++++++++++++++---------------
>   sfc.c          |   25 +++---

Looks good... will push into this release (ethtool 2.6.36)


