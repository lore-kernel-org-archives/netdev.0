From: Richard Zidlicky <rz@linux-m68k.org>
Subject: Re: 2.6.32 regression, hard lock
Date: Tue, 8 Dec 2009 10:59:39 +0100
Message-ID: <20091208095939.GA2299@linux-m68k.org>
References: <20091206141419.GA6195@linux-m68k.org> <20091207143057.53c6a362.akpm@linux-foundation.org> <20091208002353.GA30011@linux-m68k.org> <20091207164826.eb2bbc48.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Takashi Iwai <tiwai@suse.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:40243 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752934AbZLHKHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 05:07:03 -0500
Content-Disposition: inline
In-Reply-To: <20091207164826.eb2bbc48.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > I did revert to 2.31.5 and to my big surprise found a similar thing happened
> > so it is not a regression, at least not from 2.6.31.

I will compare the messages in the 2 kernel versions. In 2.6.31 the symptoms were slightly
different, the ppp connection worked long after first processes became unresponsive.
"gnome-do" was apparently the first process to hang on the spinlock and tcptrack was 
running again.

Richard
