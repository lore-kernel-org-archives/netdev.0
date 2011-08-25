From: Daniel Wagner <wagi@monom.org>
Subject: Re: [RFC] per-containers tcp buffer limitation
Date: Thu, 25 Aug 2011 20:45:02 +0200
Message-ID: <4E56982E.9090901@monom.org>
References: <4E558137.5020900@parallels.com>	<m1k4a2qqew.fsf@fess.ebiederm.org>	<4E55A55B.8090608@parallels.com>	<20110825104956.41c4b60e.kamezawa.hiroyu@jp.fujitsu.com>	<m14o16qlq1.fsf@fess.ebiederm.org>	<4E56464B.4070304@monom.org>	<4E5664B5.6000806@genband.com> <20110825084415.3c3094e8@nehalam.ftrdhcpuser.net> <4E569571.1080603@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <chris.friesen@genband.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
	Glauber Costa <glommer@parallels.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Pavel Emelyanov <xemul@parallels.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:46357 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753572Ab1HYSpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 14:45:20 -0400
In-Reply-To: <4E569571.1080603@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

> On 08/25/2011 05:44 PM, Stephen Hemminger wrote:
>> What about using netfilter (with extensions)? We already have iptables
>> module to match on uid or gid. It wouldn't be hard to extend this to
>> other bits of meta data like originating and target containers.
> 
> From reading the man pages the "owner" extension of netfilter would only
> allow to match on outgoing traffic. Would it be possible to extend this
> to also match on incoming traffic? Sorry to be completely ignorant here.

I just realized, that the "owner" extension is "only" matching on
UID/GID. For thing I would like to solve the match should be on PID.

IIRC the "owner" extension supported but this feature but it was removed [1]

thanks,
daniel

[1]
http://www.mail-archive.com/git-commits-head@vger.kernel.org/msg00486.html
