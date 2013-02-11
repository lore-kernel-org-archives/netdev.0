From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: bridge interface initial carrier state
Date: Mon, 11 Feb 2013 13:58:36 -0800
Message-ID: <20130211135836.2220ca68@nehalam.linuxnetplumber.net>
References: <1360612915.8633.6.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:37910 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932691Ab3BKV6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 16:58:53 -0500
Received: by mail-pa0-f45.google.com with SMTP id kl14so3259965pab.18
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2013 13:58:52 -0800 (PST)
In-Reply-To: <1360612915.8633.6.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Feb 2013 14:01:55 -0600
Dan Williams <dcbw@redhat.com> wrote:

> Hi,
> 
> I'm wondering if the initial carrier state of 'on' is intentional for a
> bridge without ports; immediately after adding ports, the carrier is
> recalculated and depends on the combined state of each port's carrier
> and STP forwarding state.  So a userspace program attempting to decide
> whether the bridge was usable or not has to look at both (a) how many
> ports are available and (b) bridge carrier state, instead of just
> looking at the bridge carrier state.
> 
> Dan

It really should be off when no ports are present, but some initial startup
scripts broke when it was that way.
