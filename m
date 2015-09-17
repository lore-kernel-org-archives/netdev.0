From: Jiri Benc <jbenc@redhat.com>
Subject: Re: list of all network namespaces
Date: Thu, 17 Sep 2015 11:40:59 +0200
Message-ID: <20150917114059.33431bbc@griffin>
References: <CAOxq_8Noj5oxPY5BEsWL6u4h_AD+oXYS+JCRGES_gmMQKd0rOQ@mail.gmail.com>
	<55FA0F4A.3010105@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ani Sinha <ani@arista.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56546 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752822AbbIQJlD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 05:41:03 -0400
In-Reply-To: <55FA0F4A.3010105@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Sep 2015 17:54:34 -0700, Rick Jones wrote:
> On 09/16/2015 05:46 PM, Ani Sinha wrote:
> > just a stupid question. Is it possible to get a list of all active
> > network namespaces in the kernel through /proc or some other
> > interface?

Not reliably and not efficiently. You can look at what plotnetcfg does:
https://github.com/jbenc/plotnetcfg/blob/master/netns.c

> Presumably you could copy what "ip netns" does, which appears to be to 
> look in /var/run/netns .  At least that is what an strace of that 
> command suggests.

That only works for namespaces added by the ip tool (and presumably a
few other tools which leave a symlink in /var/run/netns as a courtesy).
Depending on what you need, it may be enough. Be aware that you won't
find all net namespaces in the system this way, though.

 Jiri

-- 
Jiri Benc
