From: Thomas Graf <tgraf@suug.ch>
Subject: Re: iproute2, meta, flex parser bug?
Date: Fri, 30 Jan 2009 14:20:05 +0100
Message-ID: <20090130132005.GK20815@postel.suug.ch>
References: <200901291304.24257.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:45856 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752530AbZA3NTr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 08:19:47 -0500
Content-Disposition: inline
In-Reply-To: <200901291304.24257.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Denys Fedoryschenko <denys@visp.net.lb> 2009-01-29 13:04
> I'm trying to make meta work, without success. Seems parser done in flex 
> failing. My knowledge is not enough to fix or understand how flex is working
> Here is what i got:
> 
> home iproute2 # home iproute2 # tc/tc filter add dev eth0 protocol ip pref 11 
> basic match meta\(rt_iif eq \"eth0\"\)

Try: tc filter ... basic match 'meta(rt_iif eq <NUM>)' classid XX:YY
