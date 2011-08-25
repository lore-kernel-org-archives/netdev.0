From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] per-containers tcp buffer limitation
Date: Thu, 25 Aug 2011 08:44:15 -0700
Message-ID: <20110825084415.3c3094e8@nehalam.ftrdhcpuser.net>
References: <4E558137.5020900@parallels.com>
	<m1k4a2qqew.fsf@fess.ebiederm.org>
	<4E55A55B.8090608@parallels.com>
	<20110825104956.41c4b60e.kamezawa.hiroyu@jp.fujitsu.com>
	<m14o16qlq1.fsf@fess.ebiederm.org>
	<4E56464B.4070304@monom.org>
	<4E5664B5.6000806@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Wagner <wagi@monom.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
	Glauber Costa <glommer@parallels.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Pavel Emelyanov <xemul@parallels.com>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46925 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750910Ab1HYPoI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Aug 2011 11:44:08 -0400
In-Reply-To: <4E5664B5.6000806@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You seem to have forgotten the work of your forefathers. When appealing
to history you must understand it first.

What about using netfilter (with extensions)? We already have iptables
module to match on uid or gid. It wouldn't be hard to extend this to
other bits of meta data like originating and target containers.

You could also use this to restrict access to ports and hosts on
a per container basis.
