From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
	2.6.28
Date: Fri, 9 Jan 2009 07:54:50 +0000
Message-ID: <20090109075450.GC4605@ff.dom.local>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt> <20090108094231.GD4496@ff.dom.local> <20090108095403.GE4496@ff.dom.local> <20090108100614.GA5418@ff.dom.local> <2025.192.168.1.3.1231410939.squirrel@webmail.decimal.pt> <20090108110430.GB5493@ff.dom.local> <2111.192.168.1.3.1231413721.squirrel@webmail.decimal.pt> <20090108135927.GC5493@ff.dom.local> <2321.192.168.1.3.1231423743.squirrel@webmail.decimal.pt> <3226.192.168.1.3.1231435651.squirrel@webmail.decimal.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: mysql.jorge@decimal.pt
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:11137 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbZAIHy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 02:54:57 -0500
Received: by ug-out-1314.google.com with SMTP id 39so13347ugf.37
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2009 23:54:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <3226.192.168.1.3.1231435651.squirrel@webmail.decimal.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2009 at 05:27:31PM -0000, mysql.jorge@decimal.pt wrote:
...
> > lira:~# tc -s qdisc show dev eth0
> > qdisc cbq 1: root rate 12500000bps (bounded,isolated) prio no-transmit
> >  Sent 5336353 bytes 5737 pkts (dropped 16, overlimits 1382)
-------------------------------------------------------------> ^^^^^^^^^

BTW, I wonder why you get this output (very) old way - without "requeues"
stats. Could you tell your iproute2 and kernel (or distro) version?

Jarek P.
