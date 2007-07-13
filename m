From: "Kay Sievers" <kay.sievers@vrfy.org>
Subject: Re: [2.6.23 PATCH 13/18] dm: netlink
Date: Fri, 13 Jul 2007 09:16:31 +0200
Message-ID: <3ae72650707130016k3721e9ddube218a998a0db828@mail.gmail.com>
References: <20070711210137.GE24114@agk.fab.redhat.com>
	 <20070711142712.e646995b.akpm@linux-foundation.org>
	 <20070712231920.GZ11166@waste.org>
	 <20070712163115.ee686f8d.akpm@linux-foundation.org>
	 <20070713070321.GA10361@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	"Matt Mackall" <mpm@selenic.com>,
	"Alasdair G Kergon" <agk@redhat.com>, dm-devel@redhat.com,
	linux-kernel@vger.kernel.org, "Mike Anderson" <andmike@us.ibm.com>,
	netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:21346 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382AbXGMHQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 03:16:32 -0400
Received: by wa-out-1112.google.com with SMTP id v27so480568wah
        for <netdev@vger.kernel.org>; Fri, 13 Jul 2007 00:16:32 -0700 (PDT)
In-Reply-To: <20070713070321.GA10361@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/13/07, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> On Thu, Jul 12, 2007 at 04:31:15PM -0700, Andrew Morton (akpm@linux-foundation.org) wrote:
> > > > Need a dependency on NET there?
> > >
> > > It's really sad to make DM dependent on the network layer.
> > >
> >
> > Yes, it would be somewhat sad.  However one can presumably continue to use
> > DM, just without "DM netlink events".
>
> On my machine device mapper (lvm, raid) does not work without sockets,
> (maybe not dm, but hotplug, which creates nodes, or configuration)
> so it already depends on it. Hotplug depends on networking.
>
> You missed the day when everyone started to depend on networking :)

Right, uevents (udev) depend on networking. One could still use the
/sbin/hotplug fork-bomb, but boxes that don't want networking are
often that small, that the amount of events the kernel creates today,
leads immediately to OOM, because of too many event processes forked
at the same time.

Kay
