From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 3/7] NetLabel: CIPSOv4 engine
Date: Fri, 23 Jun 2006 13:15:12 -0700 (PDT)
Message-ID: <20060623.131512.21593290.davem@davemloft.net>
References: <20060621200031.589235000@flek.zko.hp.com>
	<20060622.021223.125894633.davem@davemloft.net>
	<1151088481.2669.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:50642
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1752007AbWFWUPN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 16:15:13 -0400
To: txtoth@gmail.com
In-Reply-To: <1151088481.2669.25.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ted <txtoth@gmail.com>
Date: Fri, 23 Jun 2006 13:48:01 -0500

> Realistically customers most likely to adopt use of SELinux are
> going to be ones that currently use other trusted OSs such as TSOL
> and HP-UX CMW.

Every single user who installs a modern distribution these days likely
gets SELINUX enabled by default, and are therefore adopters of
SELINUX.  That's a lot of people.

The number of people with existing CIPSO infrastructure are miniscule
in comparison.

Please do not even imply that CIPSO use is anything but fringe in the
grand scheme of things.  It most certainly is.  And it will be
replaced by IPSEC based labelling, that is a fact.  If people cannot
move over to IPSEC labelling simply because their HPUX/TSOL doesn't
support it, I'm perfectly happy for those users to stick with HPUX and
TSOL.  A lot of people think Linux should try to be everything for
everybody, I'm not one of those people :-)

For CIPSO we eat a non-trivial maintainence and bloat cost in order to
support legacy stuff for this relatively tiny group of potential
users.

I'd rather pay the bloat and development costs on something forward
thinking like IPSEC labelling.  Something people will actually be
using years from now, rather than a dying technology that few people
(relatively speaking) use as it is.

Finally, even if CIPSO is something we want to put in, don't worry
about it as there's still time to discuss things.  A couple days
before the merge window of 2.6.18 development closes is not the time
to be submitting half-finished work and expecting it to be integrated.
If 2.6.18 integration is what the submitter desires, they should have
finished their work and started this review process weeks if not
months ago.
