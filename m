From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 3/4] net: add NSH header structures and helpers
Date: Tue, 29 Aug 2017 19:10:49 +0200
Message-ID: <20170829191049.2d7f53e1@griffin>
References: <cover.1503948295.git.jbenc@redhat.com>
        <4abd24a9ec958622186efacb4e46d709831fbaae.1503948295.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Yi Yang <yi.y.yang@intel.com>, Eric Garver <e@erig.me>,
        Jan Scheurich <jan.scheurich@ericsson.com>,
        Ben Pfaff <blp@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60792 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751066AbdH2RKx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 13:10:53 -0400
In-Reply-To: <4abd24a9ec958622186efacb4e46d709831fbaae.1503948295.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Aug 2017 21:43:23 +0200, Jiri Benc wrote:
> This patch adds NSH header structures and helpers for NSH GSO
> support and Open vSwitch NSH support.
> 
> [1] https://datatracker.ietf.org/doc/draft-ietf-sfc-nsh/

One thing to know before applying this to the kernel: NSH is still a
draft. It's not standardized yet. And the draft evolves, compare the
version from February to the latest one:

https://tools.ietf.org/html/draft-ietf-sfc-nsh-12#section-3.2
https://tools.ietf.org/html/draft-ietf-sfc-nsh-19#section-2.2

There's really no guarantee there won't be further changes.

This patchset by itself is harmless as there's no user and everything
can be changed. We should think through any uAPIs we're going to merge,
though. We don't want to repeat the problems with VXLAN and changed UDP
port.

Again, this patchset is harmless and can be applied even if the draft
changes. Further patches may not be and need to be designed very
carefully.

 Jiri
