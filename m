From: Glenn Griffin <ggriffin.kernel@gmail.com>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Mon, 18 Feb 2008 15:45:12 -0800
Message-ID: <47ba169f.23f8720a.54d4.0229@mx.google.com>
References: <20080212.030741.132208013.yoshfuji@linux-ipv6.org>
Cc: dada1@cosmosbay.com, johnpol@2ka.mipt.ru, alan@lxorguk.ukuu.org.uk,
	andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
To: ggriffin.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:43541 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457AbYBRXhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 18:37:05 -0500
Received: by wa-out-1112.google.com with SMTP id v27so3067827wah.23
        for <netdev@vger.kernel.org>; Mon, 18 Feb 2008 15:37:05 -0800 (PST)
In-Reply-To: <20080212.030741.132208013.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've posted a series of patches that I believe address Andi's concerns
about syncookies not supporting valuable tcp options (primarily SACK,
and window scaling).  The premise being if the client support tcp
timestamps we can encode the additional tcp options in the initial
timestamp we send back to the client, and they will be echo'd back to us
in the ack.  Anyone interested have a look, and provide any suggestions
you may have.  The new patches are a superset of this patch, so if they
are accepted this is one obsolete.

Support arbitrary initial TCP timestamps
http://lkml.org/lkml/2008/2/15/244

Enable the use of TCP options with syncookies
http://lkml.org/lkml/2008/2/15/245

Add IPv6 Support to TCP SYN cookies
http://lkml.org/lkml/2008/2/15/246

--Glenn
