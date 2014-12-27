From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ipnetns: fix exec for netns not in NETNS_RUN_DIR
Date: Sat, 27 Dec 2014 10:05:48 -0800
Message-ID: <20141227100548.4fbd3e31@urahara>
References: <1419611232-14206-1-git-send-email-shahar@stratoscale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shahar Lev <shahar@stratoscale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:45841 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795AbaL0SF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Dec 2014 13:05:58 -0500
Received: by mail-pa0-f42.google.com with SMTP id et14so14877223pad.29
        for <netdev@vger.kernel.org>; Sat, 27 Dec 2014 10:05:57 -0800 (PST)
In-Reply-To: <1419611232-14206-1-git-send-email-shahar@stratoscale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Dec 2014 18:27:12 +0200
Shahar Lev <shahar@stratoscale.com> wrote:

> Enabling "ip netns exec" to be run with a net namespace
> specified by a file path rather than a filename under /var/run/nets.
> 

This breaks existing users since you now require full pathname.
