From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: updates to syncookies - timestamps not needed any more (freebsd)
Date: Fri, 12 Jul 2013 03:41:38 +0200
Message-ID: <20130712014138.GD12611@order.stressinduktion.org>
References: <20130708160421.GA9763@order.stressinduktion.org> <20130711.165726.2168148122875413191.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:40517 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932357Ab3GLBlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 21:41:39 -0400
Content-Disposition: inline
In-Reply-To: <20130711.165726.2168148122875413191.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 11, 2013 at 04:57:26PM -0700, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Mon, 8 Jul 2013 18:04:21 +0200
> 
> > Interesting patch by Andre Opperann of FreeBSD:
> > <http://lists.freebsd.org/pipermail/freebsd-net/2013-July/035999.html>
> 
> Interesting work, but outside of the change of hash function I'm not so
> sure.  The whole reason we went to the timestamp field was to eliminate
> the coarse tables.
> 
> I understand that he claims that %99.99 of connections are handled by
> the values he has chosen, but this is still a step backwards in my
> opinion.

If I understood this thread[0] correctly, it seems Windows 8 might not
enable TCP timestamps by default? I can not verify, I currently have
no Windows installations near me. That would mean, linux does, too,
fall back to an unscaled window connection as soon as syncookies kick in
(but we would not end up with an unsynchronized window scale option).

[0] http://thread.gmane.org/gmane.os.freebsd.devel.net/38211/focus=38216

Greetings,

  Hannes
