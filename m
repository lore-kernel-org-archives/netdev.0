From: Teco Boot <teco@inf-net.nl>
Subject: Re: netem: the reorder discussion
Date: Fri, 23 Aug 2013 18:18:44 +0200
Message-ID: <DF05DAC3-CED7-4615-AC02-F097EEC27752@inf-net.nl>
References: <766825FB-5295-4C5C-ABA0-CC520EFE2EA6@inf-net.nl> <1377270756.8828.5.camel@edumazet-glaptop> <20130823084450.6baf2835@nehalam.linuxnetplumber.net> <31E9BEA1-3DE2-4DA7-9CEE-6B7C9C99F5EB@inf-net.nl> <1377273838.8828.11.camel@edumazet-glaptop>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Ferry Huberts <mailings@hupie.com>,
	Netem <netem@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"core-users@pf.itd.nrl.navy.mil" <core-users@pf.itd.nrl.navy.mil>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f42.google.com ([209.85.214.42]:52781 "EHLO
	mail-bk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754939Ab3HWQTF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 12:19:05 -0400
Received: by mail-bk0-f42.google.com with SMTP id my10so311032bkb.15
        for <netdev@vger.kernel.org>; Fri, 23 Aug 2013 09:19:02 -0700 (PDT)
In-Reply-To: <1377273838.8828.11.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Op 23 aug. 2013 om 18:03 heeft Eric Dumazet <eric.dumazet@gmail.com> het volgende geschreven:

> On Fri, 2013-08-23 at 17:53 +0200, Teco Boot wrote:
> 
>> Questions that pops out of of my head: What is more important,
>> understandable configuration or keep existing behavior for unmodified
>> configuration? Do we want to reorder, even with configured rate?
>> 
>> My preference: make in understandable, document well and make all
>> sensible options available.
> 
> The day 'rate' support was added, documentation became obsolete.
> 
> Its actually hard to have both rate and delay + jitters + reorders or
> not.
> 
> If you can fix this properly, patches are welcome, but I suspect you
> wanted to reintroduce the thing that made netem unusable for us.

No, for sure I do not want to make it unusable for you. Or anybody. The opposite is true. 
I don't like the "look in souce" documentation. Or parameters with hard to understand side effects. 