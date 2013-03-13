From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: question about creating patch
Date: Wed, 13 Mar 2013 17:16:45 +0000
Message-ID: <1363195005.2683.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <CAABZP2zDU9UGRARWFBP86W28=pKa2T2mo1E8CaLAaRAu7yNSuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Zhouyi Zhou <zhouzhouyi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:10346 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932984Ab3CMRQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 13:16:49 -0400
In-Reply-To: <CAABZP2zDU9UGRARWFBP86W28=pKa2T2mo1E8CaLAaRAu7yNSuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-14 at 00:11 +0800, Zhouyi Zhou wrote:
> Dear Colleagues,
>    I have read Kushal Koolwal's article
> "HOWTO: Create and submit your first Linux kernel patch using GIT"
>  and one question remain
>  which tree is preferable in git://git.kernel.org/pub/scm/ should I
> clone in git clone step,
>  linux/kernel/git/stable/linux-stable.git
>  or
>  linux/kernel/git/davem/net.git
> Many thanks

There is an easy way to answer your question for most areas of the
kernel, which is to look for a 'T:' line in the MAINTAINERS section.
For networking you will see:

T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git

The first of these is for changes that should go into the pending
release (at present that would be 3.9), limited to important bug fixes
and (sometimes) new drivers.  The second is for new features and more
minor bug fixes that can wait for the next release.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
