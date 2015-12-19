From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] asix: silence log message from oversize packet
Date: Fri, 18 Dec 2015 16:15:03 -0800
Message-ID: <20151218161503.123b5171@xeon-e3>
References: <20151217175116.234fa63b@xeon-e3>
	<20151218.160853.1076037989795474904.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ben.hutchings@codethink.co.uk, ivecera@redhat.com,
	linuxbrad@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:34360 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbbLSAO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 19:14:58 -0500
Received: by mail-ig0-f180.google.com with SMTP id m11so2759805igk.1
        for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 16:14:57 -0800 (PST)
In-Reply-To: <20151218.160853.1076037989795474904.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Dec 2015 16:08:53 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Thu, 17 Dec 2015 17:51:16 -0800
> 
> > Since it is possible for an external system to send oversize packets
> > at anytime, it is best for driver not to print a message and spam
> > the log (potential external DoS).
> > 
> > Fixes: https://bugzilla.kernel.org/show_bug.cgi?id=109471
> > 
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> Seems reasonable, applied, thanks Stephen.

It doesn't fix the bug that is generating the oversize packet, that still needs
to be root caused.
