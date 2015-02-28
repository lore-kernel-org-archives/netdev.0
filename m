From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v4] lib: Replace 16384 netlink buf size by
 macro
Date: Fri, 27 Feb 2015 19:01:19 -0800
Message-ID: <20150227190119.0083f96f@urahara>
References: <1425018700-32725-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:38216 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbbB1DBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 22:01:18 -0500
Received: by iecrd18 with SMTP id rd18so35743944iec.5
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 19:01:17 -0800 (PST)
In-Reply-To: <1425018700-32725-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Feb 2015 08:31:40 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Replaced hard coded 16384 netlink buffer size by NLBUF_SIZE,
> which can be overridden by -DNLBUF_SIZE.
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

I agree with Dave, add -b option
