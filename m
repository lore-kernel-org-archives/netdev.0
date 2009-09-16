From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [E1000-devel] [BUG 2.6.30+] e100 sometimes causes oops during resume
Date: Thu, 17 Sep 2009 01:11:52 +0200
Message-ID: <200909170111.52204.rjw@sisk.pl>
References: <20090915120538.GA26806@bizet.domek.prywatny> <13830B75AD5A2F42848F92269B11996F5BF592C3@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Karol Lewandowski <karol.k.lewandowski@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Graham, David" <david.graham@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:38768 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752866AbZIPXKl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2009 19:10:41 -0400
In-Reply-To: <13830B75AD5A2F42848F92269B11996F5BF592C3@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 16 September 2009, Graham, David wrote:
> A v2.6.30..v2.6.31 diff shows that this is probably exposed by Rafael Wysocki's
> commit 6905b1f1, which now allows systems with e100 to sleep. If I understand
> correctly, it looks like these systems simply couldn't sleep before. Is that right Rafael?

The systems where e100 is not power manageable by any means couldn't suspend
before that commit.  For the other systems, where e100 is power manageable
either with ACPI or natively, the commit doesn't change anything. 

> I don't think its likely that the commit is a direct cause of the problem, but that the
> suspend/resume cycle now allows us to see another issue. Maybe e100 is
> leaking memory on suspend/resume cycles, or something else is leaking memory,
> or memory is becoming fragmented and the e100 driver is improperly
> requesting and being failed on an 'atomic' memory allocation  from a heavily
> fragmented memory map. Or something else.

I have a couple of test systems with e100 that don't have any resume problems,
FWIW.

Thanks,
Rafael
