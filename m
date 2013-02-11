From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] Use pkg-config to obtain xtables.h path
Date: Mon, 11 Feb 2013 09:25:33 -0800
Message-ID: <20130211092533.7ee42c58@nehalam.linuxnetplumber.net>
References: <1360185564-29094-1-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:56220 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757888Ab3BKRZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 12:25:47 -0500
Received: by mail-ia0-f174.google.com with SMTP id o25so6647125iad.33
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2013 09:25:47 -0800 (PST)
In-Reply-To: <1360185564-29094-1-git-send-email-bpoirier@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  6 Feb 2013 16:19:24 -0500
Benjamin Poirier <bpoirier@suse.de> wrote:

> On openSUSE 12.2 (at least) xtables.h is not installed in the system-wide
> include dir but in /usr/include/iptables-1.4.16.3/. This results in the
> following build failure:
> em_ipset.c:26:21: fatal error: xtables.h: No such file or directory
> 
> Other includers of xtables.h already call out to pkg-config

Accepted
