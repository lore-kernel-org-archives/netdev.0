From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
	2.6.28
Date: Fri, 9 Jan 2009 10:58:58 +0000
Message-ID: <20090109105858.GA6098@ff.dom.local>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt> <200901082357.13396.denys@visp.net.lb> <20090109103030.GI4605@ff.dom.local> <200901091232.09923.denys@visp.net.lb> <20090109104411.GJ4605@ff.dom.local> <1504.192.168.1.3.1231498031.squirrel@webmail.decimal.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Jorge Bastos <mysql.jorge@decimal.pt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:37225 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248AbZAIK7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 05:59:05 -0500
Received: by ewy10 with SMTP id 10so10134459ewy.13
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2009 02:59:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1504.192.168.1.3.1231498031.squirrel@webmail.decimal.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2009 at 10:47:11AM -0000, Jorge Bastos wrote:
> For my case this has any matter?
> 

I guess not: it's about better resolution, so e.g. when 2% matters.
And it matters for a desktop box, if you care about responsiveness.

Jarek P.

> 
> > On Fri, Jan 09, 2009 at 12:32:09PM +0200, Denys Fedoryschenko wrote:
> >> HZ still matter? With tickless kernel and hrtimers?
> >
> > Sure, "jiffies" value which depends on CONFIG_HZ is added/checked for
> > in many places in networking and elsewhere.
> >
> > Jarek P.
> >
> 
> 
