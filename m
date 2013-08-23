From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netem: the reorder discussion
Date: Fri, 23 Aug 2013 09:03:58 -0700
Message-ID: <1377273838.8828.11.camel@edumazet-glaptop>
References: <766825FB-5295-4C5C-ABA0-CC520EFE2EA6@inf-net.nl>
	 <1377270756.8828.5.camel@edumazet-glaptop>
	 <20130823084450.6baf2835@nehalam.linuxnetplumber.net>
	 <31E9BEA1-3DE2-4DA7-9CEE-6B7C9C99F5EB@inf-net.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Ferry Huberts <mailings@hupie.com>,
	Netem <netem@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"core-users@pf.itd.nrl.navy.mil" <core-users@pf.itd.nrl.navy.mil>
To: Teco Boot <teco@inf-net.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:61858 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753108Ab3HWQEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 12:04:05 -0400
Received: by mail-ee0-f54.google.com with SMTP id e53so374227eek.41
        for <netdev@vger.kernel.org>; Fri, 23 Aug 2013 09:04:04 -0700 (PDT)
In-Reply-To: <31E9BEA1-3DE2-4DA7-9CEE-6B7C9C99F5EB@inf-net.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-23 at 17:53 +0200, Teco Boot wrote:

> Questions that pops out of of my head: What is more important,
> understandable configuration or keep existing behavior for unmodified
> configuration? Do we want to reorder, even with configured rate?
> 
> My preference: make in understandable, document well and make all
> sensible options available. 

The day 'rate' support was added, documentation became obsolete.

Its actually hard to have both rate and delay + jitters + reorders or
not.

If you can fix this properly, patches are welcome, but I suspect you
wanted to reintroduce the thing that made netem unusable for us.
