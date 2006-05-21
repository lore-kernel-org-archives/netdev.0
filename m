From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCHSET 0/7] SECMARK 2.0
Date: Sun, 21 May 2006 16:54:35 -0700
Message-ID: <20060521165435.7cafbc7c.akpm@osdl.org>
References: <Pine.LNX.4.64.0605180458130.569@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaber@trash.net, sds@tycho.nsa.gov,
	netdev@vger.kernel.org, kmacmillan@tresys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:37817 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964953AbWEUXyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 May 2006 19:54:52 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0605180458130.569@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris <jmorris@namei.org> wrote:
>
> The following patchset is an updated version of secmark, which I'd like to 
>  propose for inclusion in either Dave or Andrew's tree for subsequent merge 
>  into mainline during the 2.6.18 merge window.

Well as discussed off-list, I'm not able to get this stuff to work.  I get
a pile of these:

security_compute_av:  unrecognized class 57
security_compute_av:  unrecognized class 57
security_compute_av:  unrecognized class 57
security_compute_av:  unrecognized class 57
security_compute_av:  unrecognized class 57
security_compute_av:  unrecognized class 57
security_compute_av:  unrecognized class 57
security_compute_av:  unrecognized class 57
security_compute_av:  unrecognized class 57
security_compute_av:  unrecognized class 57
security_compute_av:  unrecognized class 57
security_compute_av:  unrecognized class 57
security_compute_av:  unrecognized class 57
security_compute_av:  unrecognized class 57
security_compute_av:  unrecognized class 57
security_compute_av:  unrecognized class 57
security_compute_av:  unrecognized class 57

coming out and networking is dead.

And I'd agree with the other commenters: if these features are compulsory
for SELinux then we might as well just `select' them.  Right now it's way
too hard.

Even if we do that, the chances of people actually going off and finding
all the other random secmark Kconfig options and turning on the appropriate
ones seem pretty small.  Needs a rethink.  Perhaps a standalone secmark
menu, or just selecting everything..

And maybe just remove all the various netfilter secmark CONFIG options
altogether and make all the new code dependent upon the top-level
CONFIG_SECMARK.
