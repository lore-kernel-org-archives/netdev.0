From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH] netns: Coexist with the sysfs limitations
Date: Wed, 22 Oct 2008 16:21:24 -0500
Message-ID: <20081022212124.GA9910@us.ibm.com>
References: <20081022152144.351965414@theryb.frec.bull.fr> <m17i80nzff.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Thery <benjamin.thery@bull.net>,
	netdev <netdev@vger.kernel.org>,
	Dave Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.linux-foundation.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:45828 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408AbYJVVV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 17:21:29 -0400
Content-Disposition: inline
In-Reply-To: <m17i80nzff.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Eric W. Biederman (ebiederm@xmission.com):
> 
> To make testing of the network namespace simpler allow
> the network namespace code and the sysfs code to be
> compiled and run at the same time.  To do this only
> virtual devices are allowed in the additional network
> namespaces and those virtual devices are not placed
> in the kobject tree.
> 
> Since virtual devices don't actually do anything interesting
> hardware wise that needs device management there should
> be no loss in keeping them out of the kobject tree and
> by implication sysfs.  The gain in ease of testing
> and code coverage should be significant.
> 
> I.e. people running distributions that make it next to
> impossible to boot without sysfs should at be able to
> boot a test kernel now.
> 
> Plus no ABIs are harmed with this patch.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Duh.

Tested-by: Serge Hallyn <serue@us.ibm.com>
Acked-by: Serge Hallyn <serue@us.ibm.com>

Thanks, Eric!  Thanks, Benjamin!

-serge
