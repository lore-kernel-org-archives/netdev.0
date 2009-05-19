From: David Miller <davem@davemloft.net>
Subject: Re: tcp vegas ssthresh bugfix
Date: Tue, 19 May 2009 02:48:34 -0700 (PDT)
Message-ID: <20090519.024834.03088899.davem@davemloft.net>
References: <20090519092207.GA31493@scriptng>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: doug.leith@nuim.ie
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36297
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753006AbZESJsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 05:48:36 -0400
In-Reply-To: <20090519092207.GA31493@scriptng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Douglas Leith <doug.leith@nuim.ie>
Date: Tue, 19 May 2009 10:22:07 +0100

> This patch fixes a minor bug in tcp_vegas.c which affects ssthresh accounting
> when vegas congestion control decreases snd_cwnd.
> 
> Signed-off-by: Doug Leith <doug.leith@nuim.ie>

This patch has several problems:

> --- net/ipv4/tcp_vegas.c.orig	2009-04-27 12:55:18.000000000 +0100
> +++ net/ipv4/tcp_vegas.c	2009-05-19 09:25:17.000000000 +0100

The patch should be "-p1" based, one directory higher up.  You have
it "-p0" based.

> +					/* Update ssthresh to reflect
> +					 * decreased cwnd */

This is not the correct way to format a comment in the Linux
kernel, the correct layout is:

/* Update ssthresh to reflect
 * decreased cwnd.
 */

Please fix these problems up and resubmit.
