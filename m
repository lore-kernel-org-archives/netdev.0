From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/4][RFC] netns: sysfs: add a netns suffix to net device sysfs entries
Date: Wed, 22 Oct 2008 12:59:29 -0700
Message-ID: <m1d4hso0ym.fsf@frodo.ebiederm.org>
References: <20081022152144.351965414@theryb.frec.bull.fr>
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
Received: from out01.mta.xmission.com ([166.70.13.231]:57958 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086AbYJVUEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 16:04:39 -0400
In-Reply-To: <20081022152144.351965414@theryb.frec.bull.fr> (Benjamin Thery's
	message of "Wed, 22 Oct 2008 17:21:44 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Thery <benjamin.thery@bull.net> writes:

> Support for network namespaces in mainline is pretty complete for
> some time now, but there is still this issue with sysfs that prevents 
> more people to use it easily.

Ben your patchset is completely inappropriate.

Temporarily adding elements to the ABI that we intend to remove
is not a proper solution to this problem.

That user space visible ida you add is a namespace identifier that breaks
nested containers and migration.  It is very very very wrong.

Eric

