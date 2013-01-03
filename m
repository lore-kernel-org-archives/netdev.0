From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: order 7 allocations from xt_recent
Date: Thu, 03 Jan 2013 10:02:42 -0800
Message-ID: <1357236162.21409.25394.camel@edumazet-glaptop>
References: <20130103164315.GA18908@redhat.com>
	 <1357232104.21409.25175.camel@edumazet-glaptop>
	 <20130103171115.GA20982@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, h.reindl@thelounge.net,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:64132 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753580Ab3ACSCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 13:02:45 -0500
Received: by mail-pa0-f50.google.com with SMTP id hz10so8811687pad.23
        for <netdev@vger.kernel.org>; Thu, 03 Jan 2013 10:02:44 -0800 (PST)
In-Reply-To: <20130103171115.GA20982@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-03 at 12:11 -0500, Dave Jones wrote:

> That 'check size and vmalloc/kmalloc accordingly' thing seems to be a pattern
> that comes up time and time again.  Is it worth maybe making a more generic
> version of that instead of open-coding it each time it comes up ?

We had numerous discussions and patch submissions in the past, and this
went nowhere. I am not sure anybody wants to spend more cycles on this.

Its sad, but true.
