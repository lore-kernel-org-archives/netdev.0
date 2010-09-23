From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 8/8] net: Implement socketat.
Date: Thu, 23 Sep 2010 15:53:00 +0400
Message-ID: <4C9B3F9C.8080506@parallels.com>
References: <m1ocborgq7.fsf@fess.ebiederm.org>	 <m1bp7oq1u8.fsf@fess.ebiederm.org>  <4C9B162E.7040201@parallels.com>	 <1285240797.5036.5.camel@bigi>  <4C9B3B06.900@parallels.com> <1285242055.5036.9.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Ulrich Drepper <drepper@gmail.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Ben Greear <greearb@candelatech.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:31378 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754528Ab0IWLyX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Sep 2010 07:54:23 -0400
In-Reply-To: <1285242055.5036.9.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/23/2010 03:40 PM, jamal wrote:
> On Thu, 2010-09-23 at 15:33 +0400, Pavel Emelyanov wrote:
> 
>> This particular usecase is unneeded once you have the "enter" ability.
> 
> Is that cheaper from a syscall count/cost?

Why does it matter? You told, that the usage scenario was to
add routes to container. If I do 2 syscalls instead of 1, is
it THAT worse?

> i.e do I have to enter every time i want to write/read this fd?

No - you enter once, create a socket and do whatever you need
withing the enterned namespace.

> How does poll/select work in that enter scenario?

Just like it used to before the enter.

> cheers,
> jamal
> 
> 

