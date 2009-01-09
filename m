From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
	2.6.28
Date: Fri, 9 Jan 2009 10:02:23 +0000
Message-ID: <20090109100223.GE4605@ff.dom.local>
References: <20090108095403.GE4496@ff.dom.local> <20090108100614.GA5418@ff.dom.local> <2025.192.168.1.3.1231410939.squirrel@webmail.decimal.pt> <20090108110430.GB5493@ff.dom.local> <2111.192.168.1.3.1231413721.squirrel@webmail.decimal.pt> <20090108135927.GC5493@ff.dom.local> <2321.192.168.1.3.1231423743.squirrel@webmail.decimal.pt> <3226.192.168.1.3.1231435651.squirrel@webmail.decimal.pt> <20090109072452.GA4605@ff.dom.local> <1052.192.168.1.3.1231493984.squirrel@webmail.decimal.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Jorge Bastos <mysql.jorge@decimal.pt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:38787 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754006AbZAIKCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 05:02:30 -0500
Received: by ewy10 with SMTP id 10so10109416ewy.13
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2009 02:02:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1052.192.168.1.3.1231493984.squirrel@webmail.decimal.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2009 at 09:39:44AM -0000, Jorge Bastos wrote:
> Going to.
> But tell me, for this, all 3 params should be disabled, correct?

Yes, but only if you are doing packet scheduling on an interface.
Otherwise they could be needed to get full performance from new
network cards.

Jarek P. 
