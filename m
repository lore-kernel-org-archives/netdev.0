From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/4][RFC] netns: sysfs: add a netns suffix to net device sysfs entries
Date: Thu, 23 Oct 2008 08:46:56 -0700
Message-ID: <m1od1biaa7.fsf@frodo.ebiederm.org>
References: <20081022152144.351965414@theryb.frec.bull.fr>
	<m1d4hso0ym.fsf@frodo.ebiederm.org> <49006671.3010804@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Dave Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Al Viro <viro@ftp.linux.org.uk>,
	Serge Hallyn <serue@us.ibm.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.linux-foundation.org>
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:34746 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335AbYJWPyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 11:54:32 -0400
In-Reply-To: <49006671.3010804@bull.net> (Benjamin Thery's message of "Thu, 23
	Oct 2008 13:56:33 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Thery <benjamin.thery@bull.net> writes:

> In fact, I feared that would be an issue before I sent the patches.
> Thanks for confirming this.
>
> But, as this alternative was discussed a bit after Al's comments on your
> last patches, I had to give it a try and code a proof-of-concept.

Yes.  We have a lot of reasons now for why that approach is a
bad idea.  Which should help a lot when it comes to handling sysfs
properly.

Eric
