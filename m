From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ethtool: Do not report link partner advertising flags
 if set to 0
Date: Sun, 20 Dec 2009 15:34:04 -0500
Message-ID: <4B2E8A3C.9000908@garzik.org>
References: <1261336350.25157.200.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kurt Roeckx <kurt@roeckx.be>, 561843@bugs.debian.org,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.211.182]:57919 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950AbZLTUeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Dec 2009 15:34:10 -0500
Received: by ywh12 with SMTP id 12so5058401ywh.21
        for <netdev@vger.kernel.org>; Sun, 20 Dec 2009 12:34:08 -0800 (PST)
In-Reply-To: <1261336350.25157.200.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2009 02:12 PM, Ben Hutchings wrote:
> Only some drivers (and none before kernel version 2.6.31) currently
> set these flags.  When the flags are equal to 0 and so we don't know
> what the link partner advertised, don't report anything.
>
> Signed-off-by: Ben Hutchings<ben@decadent.org.uk>
> ---
>   ethtool.c |    4 +++-
>   1 files changed, 3 insertions(+), 1 deletions(-)

applied


