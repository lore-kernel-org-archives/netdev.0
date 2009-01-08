From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
	2.6.28
Date: Thu, 8 Jan 2009 09:54:03 +0000
Message-ID: <20090108095403.GE4496@ff.dom.local>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt> <20090108094231.GD4496@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: mysql.jorge@decimal.pt
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f31.google.com ([209.85.219.31]:51964 "EHLO
	mail-ew0-f31.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189AbZAHJyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 04:54:15 -0500
Received: by ewy12 with SMTP id 12so3097816ewy.13
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2009 01:54:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20090108094231.GD4496@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2009 at 09:42:31AM +0000, Jarek Poplawski wrote:
> On 08-01-2009 00:42, mysql.jorge@decimal.pt wrote:
> > Is there anyway to debug this?
> 
> Could you try: ethtool -k eth0
> with quite fresh ethtool, and to turn off GSO etc., if it's on?

Hmm... Actually, it's probably about config: I'm not cbq user or
expert, but AFAIK it depends on precise info about the real link
rate, so it probably needs an update to 1000Mbit.

Jarek P.
