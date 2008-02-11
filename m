From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Mon, 11 Feb 2008 23:42:12 +0000
Message-ID: <47B0DD54.5000100@katalix.com>
References: <200802110922.m1B9MKQ4003674@quickie.katalix.com> <47B09A90.7040508@gmail.com> <47B0C9F7.5040200@katalix.com> <20080211224924.GA2863@ami.dom.local> <20080211225533.GB2863@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:60036 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755006AbYBKXmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 18:42:17 -0500
In-Reply-To: <20080211225533.GB2863@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Mon, Feb 11, 2008 at 11:49:24PM +0100, Jarek Poplawski wrote:
>> On Mon, Feb 11, 2008 at 10:19:35PM +0000, James Chapman wrote:
>> ...
>>> Below is example output from lockdep. The oops is reproducible when  
>>> creating/deleting lots of sessions while passing data. The lock is being  
>>> acquired for read and write in softirq contexts.
> 
> ...Hmmm... And according to this, changing read_locks should be
> necessary too.

The patch changes both read and write locks.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

