From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: [RFC] per-containers tcp buffer limitation
Date: Thu, 25 Aug 2011 09:05:25 -0600
Message-ID: <4E5664B5.6000806@genband.com>
References: <4E558137.5020900@parallels.com> <m1k4a2qqew.fsf@fess.ebiederm.org> <4E55A55B.8090608@parallels.com> <20110825104956.41c4b60e.kamezawa.hiroyu@jp.fujitsu.com> <m14o16qlq1.fsf@fess.ebiederm.org> <4E56464B.4070304@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
	Glauber Costa <glommer@parallels.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Pavel Emelyanov <xemul@parallels.com>
To: Daniel Wagner <wagi@monom.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og120.obsmtp.com ([64.18.2.18]:45197 "EHLO
	exprod7og120.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573Ab1HYPFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 11:05:54 -0400
In-Reply-To: <4E56464B.4070304@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2011 06:55 AM, Daniel Wagner wrote:

> I'd like to solve a use case where it is necessary to count all bytes
> transmitted and received by an application [1]. So far I have found two
> unsatisfying solution for it. The first one is to hook into libc and
> count the bytes there. I don't think I have to say I don't like this.

Is there any particular reason you can't use LD_PRELOAD to interpose a 
library to do the statistics monitoring?

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
