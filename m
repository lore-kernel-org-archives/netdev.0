From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Network privilege separation.
Date: Mon, 12 Jan 2009 20:43:33 +0100
Message-ID: <20090112194333.GB23848@one.firstfloor.org>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <87mye2yg8a.fsf@basil.nowhere.org> <20090108023111.GJ3164@didacte.laptop.org> <20090108104305.7b271053@lxorguk.ukuu.org.uk> <12821.1231785850@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Michael Stone <michael@laptop.org>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:41982 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbZALT3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 14:29:04 -0500
Content-Disposition: inline
In-Reply-To: <12821.1231785850@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Yes, the network access part *is* something that should be part of a more
> general interface.  Having said that, we currently are lacking a way for a
> *general user* program to say "I'm all set up, and would like to disavow any
> other further resource access (except maybe r/o access as "other" to file
> systems)".

seccomp does exactly that. It's quite obscure, but available in most
linux kernels. Basically it blocks everything except
read/write on already open file descriptors.

I always thought it would be nice if codecs (which tend
to be full of security holes) ran in such jails by default

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only.
