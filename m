From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] iproute2: split up ip man page?
Date: Thu, 22 Dec 2011 10:37:23 -0800
Message-ID: <20111222103723.59a035df@nehalam.linuxnetplumber.net>
References: <20111207131514.6815f813@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39398 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752448Ab1LVShZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Dec 2011 13:37:25 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id A92BA141000D
	for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 10:37:25 -0800 (PST)
In-Reply-To: <20111207131514.6815f813@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 Dec 2011 13:15:14 -0800
Stephen Hemminger <shemminger@vyatta.com> wrote:

> The current ip man page is both incomplete and so big that
> the actual functions get lost easily.
> 
> I propose splitting the the pages for the subfunction
> into sub pages. The man command appears
> to be smart enough to handle:
>   man tc htb
> 
> and pickup the manpage for /usr/share/man/man1/tc-htb.8.gz
> Why not do the same thing for ip command?
> 
> The base ip page would just be a place holder that covered the
> generic arguments.
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Ok, the ip man page is now broken up. I tried to fix some of the
incorrect grammar and usage as well. The pages still need editing for
readability.

Added a few examples as well.

Please download from the git repository and send me any comments
or changes.

   git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git
