From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
	2.6.28
Date: Fri, 9 Jan 2009 10:30:30 +0000
Message-ID: <20090109103030.GI4605@ff.dom.local>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt> <200901082041.58597.denys@visp.net.lb> <1059.87.196.62.168.1231451164.squirrel@webmail.decimal.pt> <200901082357.13396.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jorge Bastos <mysql.jorge@decimal.pt>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:44752 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbZAIKah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 05:30:37 -0500
Received: by ewy10 with SMTP id 10so10122185ewy.13
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2009 02:30:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <200901082357.13396.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2009 at 11:57:13PM +0200, Denys Fedoryschenko wrote:
> Can 100HZ be issue?

Generally, if you need precise scheduling HZ=1000 should be used if
higher cpu usage isn't a problem.

Jarek P.
