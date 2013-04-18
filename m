From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] vxlan: add ipv6 support
Date: Thu, 18 Apr 2013 15:57:03 -0700
Message-ID: <20130418155703.251298c3@nehalam.linuxnetplumber.net>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
	<1366175423-27310-7-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:45290 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753496Ab3DRW5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 18:57:35 -0400
Received: by mail-da0-f53.google.com with SMTP id n34so1603581dal.26
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 15:57:34 -0700 (PDT)
In-Reply-To: <1366175423-27310-7-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Apr 2013 13:10:23 +0800
Cong Wang <amwang@redhat.com> wrote:

> +			if (!inet_pton(AF_INET, *argv, &gaddr)) {
> +				if (!inet_pton(AF_INET6, *argv, &gaddr6)) {
> +					fprintf(stderr, "Invalid address \"%s\"\n", *argv);
> +					return -1;
> +				} else if (!IN6_IS_ADDR_MULTICAST(&gaddr6))
> +					invarg("invald group address", *argv);
> +			} else if (!IN_MULTICAST(ntohl(gaddr)))
> +					invarg("invald group address", *argv);

Maybe using getaddrinfo would be better to allow symbolic names as well?
