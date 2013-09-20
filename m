From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/4] mISDN: add support for group membership check
Date: Fri, 20 Sep 2013 13:14:03 -0400 (EDT)
Message-ID: <20130920.131403.1652318883820150146.davem@davemloft.net>
References: <523C753A.8040401@suse.cz>
	<20130920.122142.1032350399957506112.davem@davemloft.net>
	<20130920163043.GN7729@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jslaby@suse.cz, akpm@linux-foundation.org, jeffm@suse.com,
	netdev@vger.kernel.org, isdn4linux@koppen.de, isdn@linux-pingi.de,
	sergei.shtylyov@cogentembedded.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38350 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204Ab3ITROI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 13:14:08 -0400
In-Reply-To: <20130920163043.GN7729@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 20 Sep 2013 17:30:44 +0100

> On Fri, Sep 20, 2013 at 12:21:42PM -0400, David Miller wrote:
>> From: Jiri Slaby <jslaby@suse.cz>
>> Date: Fri, 20 Sep 2013 18:18:02 +0200
>> 
>> > Ok, let's leave the hole in there then.
>> 
>> Jiri, don't turn this on me.
>> 
>> The issue is not whether something needs to be fixed or not, I never
>> said "don't fix this" and therefore I'd like to ask politely that you
>> not make it seem like I have.
>> 
>> Rather, I'm saying that the implementation is terrible, sets a bad
>> precendence for fixing similar problems, and therefore not is in
>> a state where we can apply it.
>> 
>> So, I'm not saying "don't fix this", I'm saying "fix it properly."
> 
> I think Jiri's last suggestion was to add the capability check to
> device renaming (which I think everyone agrees is needed) and not
> to add any group identity checks for any operation.
> 
> Isn't that fixing it properly?

I'm saying that using a module parameter for this is a deeper and
even more important problem with this change.

He seems to agree with me.
