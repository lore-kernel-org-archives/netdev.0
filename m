From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 12/16] net: Support multiple network namespaces with netlink
Date: Mon, 10 Sep 2007 09:24:23 -0600
Message-ID: <m1lkber1aw.fsf@ebiederm.dsl.xmission.com>
References: <m1r6l8x3vq.fsf@ebiederm.dsl.xmission.com>
	<m1myvwx3sf.fsf@ebiederm.dsl.xmission.com>
	<m1ir6kx3mn.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com>
	<m1abrwx3g0.fsf_-_@ebiederm.dsl.xmission.com>
	<m1642kx3e3.fsf_-_@ebiederm.dsl.xmission.com>
	<m11wd8x3a3.fsf_-_@ebiederm.dsl.xmission.com>
	<m1sl5ovolm.fsf_-_@ebiederm.dsl.xmission.com>
	<m1odgcvoje.fsf_-_@ebiederm.dsl.xmission.com>
	<m1k5r0voh4.fsf_-_@ebiederm.dsl.xmission.com>
	<m1fy1ovoeo.fsf_-_@ebiederm.dsl.xmission.com>
	<m1bqccvock.fsf_-_@ebiederm.dsl.xmission.com>
	<46E54AC8.7000609@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:53692 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757833AbXIJPYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 11:24:53 -0400
In-Reply-To: <46E54AC8.7000609@openvz.org> (Pavel Emelyanov's message of "Mon,
	10 Sep 2007 17:46:48 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov <xemul@openvz.org> writes:
>
> Rrrrrr. This is the 5th or even the 6th patch that changes tens of files
> but (!) most of these changes are just propagating some core thing into
> protocols, drivers, etc. E.g. you add an argument to some function and
> then make all the rest use it, but the chunk adding the argument itself
> is buried in these changes.
>
> Why not make a reviewers' lifes easier and make (with hands) the core 
> hunks go first and the "propagation" ones at the end? For RFC purpose 
> I would even break the git-bisect safeness and splitted these patches 
> into 2 parts: those with the core and those with the propagation.

Agreed, this is an issue for easy review. My apologies.

I guess it was a failure in my imagination on how to prepare these
patches for review, in a way that was both reviewer and preparer friendly.

There is at least one /proc idiom change that needs to be made so I
will keep this in mind for the resend.

Eric
