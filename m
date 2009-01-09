From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
	2.6.28
Date: Fri, 9 Jan 2009 10:44:11 +0000
Message-ID: <20090109104411.GJ4605@ff.dom.local>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt> <200901082357.13396.denys@visp.net.lb> <20090109103030.GI4605@ff.dom.local> <200901091232.09923.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jorge Bastos <mysql.jorge@decimal.pt>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.176]:20012 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751687AbZAIKoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 05:44:18 -0500
Received: by ik-out-1112.google.com with SMTP id c29so1979263ika.5
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2009 02:44:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <200901091232.09923.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2009 at 12:32:09PM +0200, Denys Fedoryschenko wrote:
> HZ still matter? With tickless kernel and hrtimers?

Sure, "jiffies" value which depends on CONFIG_HZ is added/checked for
in many places in networking and elsewhere.

Jarek P.
