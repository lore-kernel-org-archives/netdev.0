From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net-next 2/6] bridge: make flags sysfs interface a
 little bit more extensible
Date: Fri, 19 Apr 2013 13:54:41 -0700
Message-ID: <20130419135441.2dc84327@nehalam.linuxnetplumber.net>
References: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
	<1366404770-28523-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	mst@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:54719 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932301Ab3DSUzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 16:55:14 -0400
Received: by mail-pd0-f182.google.com with SMTP id 3so2421279pdj.27
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 13:55:13 -0700 (PDT)
In-Reply-To: <1366404770-28523-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Apr 2013 16:52:46 -0400
Vlad Yasevich <vyasevic@redhat.com> wrote:

>  
> +static ssize_t show_flag(struct net_bridge_port *p, char *buf,
> +			  unsigned long mask)
> +{
> +	return sprintf(buf, "%d\n", !!(p->flags & mask));
> +}

Flags are bit, show in hex please.
