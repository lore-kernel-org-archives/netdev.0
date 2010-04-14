From: Richard Zidlicky <rz@linux-m68k.org>
Subject: Re: usb-sound circular locking again?
Date: Wed, 14 Apr 2010 10:26:49 +0200
Message-ID: <20100414082649.GA24251@linux-m68k.org>
References: <20091206141419.GA6195@linux-m68k.org> <20091207143057.53c6a362.akpm@linux-foundation.org> <20091208002353.GA30011@linux-m68k.org> <20091207164826.eb2bbc48.akpm@linux-foundation.org> <s5hocm9som6.wl%tiwai@suse.de> <20100413203039.GC8468@linux-m68k.org> <s5h4oje5zl9.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Takashi Iwai <tiwai@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:53616 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440Ab0DNIYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 04:24:20 -0400
Content-Disposition: inline
In-Reply-To: <s5h4oje5zl9.wl%tiwai@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> > is this the same old issue?
> 
> I think so.  It appears relatively new since a sysfs lockdep check was
> introduced.

you are right, it was definitely my impression that this particular instance is 
a new (last previously tested 2.6.32.8).
After a few more tests it appears to be 100% repeatable in pm-hibernate. Simply 
doing "sync" right now does nothing.

Richard
