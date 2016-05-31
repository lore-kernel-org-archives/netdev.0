From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/3] nl80211: Fix checkpatch warnings
Date: Tue, 31 May 2016 12:29:42 +0200
Message-ID: <1464690582.3076.21.camel@sipsolutions.net>
References: <cover.1464492195.git.kirtika.ruchandani@gmail.com>
	 <487a841acb1098e96104f2671399274e82aafeba.1464492195.git.kirtika.ruchandani@gmail.com>
	 <CAGRGNgXuE3smks0pYoMQ5NxqjUN0PJ7i6LgBDjkq_uWyfPHQkA@mail.gmail.com>
	 (sfid-20160530_023028_641313_76E294B4)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	Kirtika Ruchandani <kirtika.ruchandani@gmail.com>,
	ruchandani.tina@gmail.com, netdev <netdev@vger.kernel.org>
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:40623 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751249AbcEaK3q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 May 2016 06:29:46 -0400
In-Reply-To: <CAGRGNgXuE3smks0pYoMQ5NxqjUN0PJ7i6LgBDjkq_uWyfPHQkA@mail.gmail.com> (sfid-20160530_023028_641313_76E294B4)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-05-30 at 10:30 +1000, Julian Calaby wrote:
> Hi All,
> 
> On Sun, May 29, 2016 at 1:30 PM, Kirtika Ruchandani
> <kirtika.ruchandani@gmail.com> wrote:
> > 
> > This patch fixes the following checkpatch.pl warnings about
> > comments in nl80211.c :
> > - networking block comments don't use an empty '/*' line
> > - block comments use a trailing '*/' on a separate line
> > 
> > Signed-off-by: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
> The change and logic behind it are sound, so it gets my:
> 
> Reviewed-by: Julian Calaby <julian.calaby@gmail.com>
> 
> however I'm concerned that this file is a deliberate exception to the
> networking comment rules.
> 

It's kinda mixed, I never really enforced one style or the other ...
I'm kinda taking both now, with a slight preference towards the
networking style perhaps (to please davem :) )

That said, in general I'm not really sure of the value of all of these
patches - perhaps the kcalloc() one makes sense, not for checkpatch
reasons but rather for size limit/integer overflow reasons, and the
ether address assign for general readability, but overall ...

I'll have to make up my mind :)

johannes
