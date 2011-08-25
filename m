From: Daniel Wagner <wagi@monom.org>
Subject: Re: [RFC] per-containers tcp buffer limitation
Date: Thu, 25 Aug 2011 20:27:54 +0200
Message-ID: <4E56942A.3080905@monom.org>
References: <4E558137.5020900@parallels.com> <m1k4a2qqew.fsf@fess.ebiederm.org> <4E55A55B.8090608@parallels.com> <20110825104956.41c4b60e.kamezawa.hiroyu@jp.fujitsu.com> <m14o16qlq1.fsf@fess.ebiederm.org> <4E56464B.4070304@monom.org> <4E5664B5.6000806@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
	Glauber Costa <glommer@parallels.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Pavel Emelyanov <xemul@parallels.com>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:49987 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753617Ab1HYS2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 14:28:12 -0400
In-Reply-To: <4E5664B5.6000806@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chris,

On 08/25/2011 05:05 PM, Chris Friesen wrote:
> On 08/25/2011 06:55 AM, Daniel Wagner wrote:
> 
>> I'd like to solve a use case where it is necessary to count all bytes
>> transmitted and received by an application [1]. So far I have found two
>> unsatisfying solution for it. The first one is to hook into libc and
>> count the bytes there. I don't think I have to say I don't like this.
> 
> Is there any particular reason you can't use LD_PRELOAD to interpose a
> library to do the statistics monitoring?

This is certainly possible to do for any dynamic linked application. I
think it wouldn't work for static linked ones. Currently I don't know if
I have to face such application on the project I am on. The reason why I
am not so a big fan is that using the LD_PRELOAD trick seems very
hackish to me.

As Glauber has argumented in this thread, there are properly quite a few
people who want to control or monitor sockets. It seems I am one of
those. Having this kind of support in cgroups seems like a very neat
solution to me.

thanks,
daniel
