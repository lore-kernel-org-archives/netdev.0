From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 0/2] Fix /proc/net in presence of net namespaces
Date: Fri, 29 Feb 2008 10:44:03 +0300
Message-ID: <47C7B7C3.4000504@openvz.org>
References: <47C6D743.1050802@openvz.org> <m1y794514k.fsf@ebiederm.dsl.xmission.com> <20080228211720.GA1232@vino.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: serge@hallyn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41770 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752201AbYB2HoR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 02:44:17 -0500
In-Reply-To: <20080228211720.GA1232@vino.hallyn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Nack.  Yet another global set of ids that require us to implement another
>> namespace looks like the wrong way to go.
> 
> Sentiment granted, but I'm not sure it can be an issue.  It *could* be
> in issue if we moved to a more flexible access control here here any
> netns could access the .netns/N directories for all it's child
> namespaces.
> 
> But it can't, and /proc/net is set by the kernel.  So the <id> can't be
> an issue for any checkpoint/restart except htat of the whole system, and
> of course on whole-system resume we have no <id> collision worries.
> 
> So userspace can't do anything with <id>, so there is no reason to worry
> about it becoming another namespace?
> 
> Right?

Right. Thanks, Serge.

> thanks,
> -serge
