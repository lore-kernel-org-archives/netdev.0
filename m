From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG 12364] Re: HTB - very bad precision? HFSC works fine!
	2.6.28
Date: Thu, 8 Jan 2009 09:42:32 +0000
Message-ID: <20090108094231.GD4496@ff.dom.local>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: mysql.jorge@decimal.pt
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f31.google.com ([209.85.219.31]:45069 "EHLO
	mail-ew0-f31.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754023AbZAHJmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 04:42:38 -0500
Received: by ewy12 with SMTP id 12so3096215ewy.13
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2009 01:42:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08-01-2009 00:42, mysql.jorge@decimal.pt wrote:
> Is there anyway to debug this?

Could you try: ethtool -k eth0
with quite fresh ethtool, and to turn off GSO etc., if it's on?

Jarek P.
