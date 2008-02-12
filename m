From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Tue, 12 Feb 2008 10:42:08 +0000
Message-ID: <20080212104208.GD2582@ff.dom.local>
References: <200802110922.m1B9MKQ4003674@quickie.katalix.com> <47B09A90.7040508@gmail.com> <47B0C9F7.5040200@katalix.com> <20080211224924.GA2863@ami.dom.local> <20080211225533.GB2863@ami.dom.local> <47B0DD54.5000100@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:64199 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760138AbYBLKe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 05:34:56 -0500
Received: by ug-out-1314.google.com with SMTP id z38so456455ugc.16
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2008 02:34:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47B0DD54.5000100@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 11, 2008 at 11:42:12PM +0000, James Chapman wrote:
> Jarek Poplawski wrote:
>> On Mon, Feb 11, 2008 at 11:49:24PM +0100, Jarek Poplawski wrote:
>>> On Mon, Feb 11, 2008 at 10:19:35PM +0000, James Chapman wrote:
>>> ...
>>>> Below is example output from lockdep. The oops is reproducible when 
>>>>  creating/deleting lots of sessions while passing data. The lock is 
>>>> being  acquired for read and write in softirq contexts.
>>
>> ...Hmmm... And according to this, changing read_locks should be
>> necessary too.
>
> The patch changes both read and write locks.

Right! This was only "errata" to my earlier comment where I considered
only lockdep info and forgot about yours...

Sorry,
Jarek P.
