From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] sysfs: Don't allow the creation of symlinks we can't
 remove
Date: Sat, 10 Jul 2010 23:30:15 +0100 (BST)
Message-ID: <alpine.LFD.2.00.1007102329000.11778@eddie.linux-mips.org>
References: <bug-16257-10286@https.bugzilla.kernel.org/>        <20100621150826.762ac9f2.akpm@linux-foundation.org>        <m1mxuodo0n.fsf@fess.ebiederm.org> <20100621222938.GA20583@suse.de>        <m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de>
        <m14ogwc4ou.fsf@fess.ebiederm.org> <20100622035631.GA3755@suse.de> <m1630q7x5v.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:51171 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190Ab0GJWfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 18:35:19 -0400
Received: from localhost.localdomain ([127.0.0.1]:51220 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S1492164Ab0GJWaP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 00:30:15 +0200
In-Reply-To: <m1630q7x5v.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 Jul 2010, Eric W. Biederman wrote:

> Recently my tagged sysfs support revealed a flaw in the device core
> that a few rare drivers are running into such that we don't always put
> network devices in a class subdirectory named net/.

 I've been cc-ed for a reason I suppose -- any network driver I should be 
looking into?  What's the actual problem?

  Maciej
