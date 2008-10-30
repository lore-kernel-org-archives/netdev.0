From: Thomas Graf <tgraf@suug.ch>
Subject: Re: pkt_sched: Control group classifier
Date: Thu, 30 Oct 2008 14:10:08 +0100
Message-ID: <20081030131008.GK20815@postel.suug.ch>
References: <20081027.123056.22851224.davem@davemloft.net> <20081027.170524.124746723.davem@davemloft.net> <20081030105431.GI20815@postel.suug.ch> <166fe7950810300457h3b1c11c9m437aab08ddc8afa3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ranjit Manomohan <ranjitm@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53697 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751600AbYJ3NJs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2008 09:09:48 -0400
Content-Disposition: inline
In-Reply-To: <166fe7950810300457h3b1c11c9m437aab08ddc8afa3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Ranjit Manomohan <ranjitm@google.com> 2008-10-30 04:57
> The complexity of migrating open sockets across cgroups can easily be
> fixed if it is deemed to be a problem but is unlikely to be a big
> issue for most workloads like browsers or web servers.

Can you explain how to assign the PIDs to cgroups before the process
is created? Are there any special tools to achieve that? Or do you
intentionally limit the functionality to sockets which are created
after the process is assigned to the cgroup? I would be interested to
see a typical usage example of your approach in order to understand
it better.

Fixing the migration of open sockets is definitely not a problem but
how do you plan on assigning the class identifier to sockets which
already exist when a process is assigned to a cgroup? Do you intend
to walk through all open file descriptors?
