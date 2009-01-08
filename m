From: david@lang.hm
Subject: Re: RFC: Network privilege separation.
Date: Wed, 7 Jan 2009 23:52:29 -0800 (PST)
Message-ID: <alpine.DEB.1.10.0901072350480.31038@asgard.lang.hm>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <87mye2yg8a.fsf@basil.nowhere.org> <20090108023111.GJ3164@didacte.laptop.org> <20090108031042.GQ496@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Michael Stone <michael@laptop.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.lang.hm ([64.81.33.126]:39068 "EHLO bifrost.lang.hm"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751081AbZAHGtz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 01:49:55 -0500
In-Reply-To: <20090108031042.GQ496@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 Jan 2009, Andi Kleen wrote:

> On Wed, Jan 07, 2009 at 09:31:11PM -0500, Michael Stone wrote:
>>     -- if it's different from Joe User's regular uid, then where did it come
>>        from and how is Joe going to clean it up when he no longer needs it?
>
> You always create  joe-nonet one when you create joe
>
> Now writing to joe's files: you can either use ACLs or do everything
> through group accesses (it's very common to have a "joe" group for this
> purpose for each user)
>
> But perhaps it's a good idea to not allow writing to all of Joe's
> files by those "no network" processes too. It at least sounds like
> that might be useful to combine.

there are times when that would be nice, but it's also a bit of a pain to 
have to change the permissions so that joe-nonet can access all the files 
that joe can access (they will have to be set with the correct group 
ownership and hope that there wasn't a reason to use any other group)

David Lang
