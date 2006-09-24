From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 0/2] crc-itu-t
Date: Sun, 24 Sep 2006 18:45:20 +0200
Message-ID: <200609241845.20329.IvDoorn@gmail.com>
References: <200608081621.52132.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:25035 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1750762AbWIXQqC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Sep 2006 12:46:02 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1346743nfa
        for <netdev@vger.kernel.org>; Sun, 24 Sep 2006 09:46:00 -0700 (PDT)
To: linville@tuxdriver.com
In-Reply-To: <200608081621.52132.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

Is there any particular reason this patch has been held back?
It has been send to the kernel mailinglist several times as well,
and there didn't seem to be any objections against it, except
for some coding style errors which had been fixed.
The second objection, which wasn't said so explicitely but
was still clear was that it cannot go into the main kernel tree
since there is no driver using it. That makes the only acceptable
place for now wireless-dev since rt2x00 wishes to use it. ;)

The last 2 attempts I had send the patch to the kernel tree
remained unanswered and I am unsure who should
aprove this patch before it can be added to the lib/ directory.

Ivo

> These patches are for wireless-dev
> and will add a crc-itu-t implementation to the lib/ directory.
> Some drivers are currently using there own version
> of this crc routine so there could be usefull to add
> this to lib/
> 
> The second patch is to make rt2x00 use this crc-itu-t library
> and removes its own version of the crc check.
> 
> Ivo
> 
