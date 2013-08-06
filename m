From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: linux-next: Tree for Aug 6 [ wireless | iwlwifi | mac80211 ? ]
Date: Tue, 06 Aug 2013 21:18:35 +0200
Message-ID: <1375816715.8219.29.camel@jlt4.sipsolutions.net>
References: <CA+icZUX8OcTSOABO6Nbz5R6_5-m39rsYOpDqYBA7hf8LFvJLLA@mail.gmail.com>
	 <1375797260.8219.21.camel@jlt4.sipsolutions.net>
	 <CA+icZUUAJ25QybqHvxz7eubSLH6YuNjcc5zyU2O5Xi9vevMGkw@mail.gmail.com>
	 <1375800617.8219.23.camel@jlt4.sipsolutions.net>
	 <CA+icZUVbKpyuke6PRg3-60gOggsTb=3cNRz3Sy0RmvcZSuPaNw@mail.gmail.com>
	 <1375801059.8219.24.camel@jlt4.sipsolutions.net>
	 <CA+icZUXrRsXfeW9hqxTMkKW4TdNSBH-zE8-zX2Rd7HTAx5MvqQ@mail.gmail.com>
	 <CA+icZUWijPJmNoqE22Msqcn7tRot3SB3e=KujMM7JNd-Om-oOw@mail.gmail.com>
	 <1375802297.8219.25.camel@jlt4.sipsolutions.net>
	 <CA+icZUVCFOS6SHonEqzaJyWCGCU4nqqGjBN0VbmV-=OoM+deZg@mail.gmail.com>
	 <CA+icZUVuOqdZUGy2ALAF1CehOqYdr7rtEsXhqNvDtYEns2BuRQ@mail.gmail.com>
	 <1375802993.8219.26.camel@jlt4.sipsolutions.net>
	 <CA+icZUW6P9Z_7z+o+z=qBWSFzyU8tgtY0ou+rmLcEzWbn94OXA@mail.gmail.com>
	 <CA+icZUW7LVzg7sM3O-w5oQpeaj=CT6MS6Q7cRZ1qK0h-Z4wZuw@mail.gmail.com>
	 <1375804998.8219.27.camel@jlt4.sipsolutions.net>
	 <CA+icZUVRgVfXUdJ1xoaN=nciqZDhV-f6EbH+6DS7HAh+My65oQ@mail.gmail.com>
	 <CA+icZUUmQbovkwXcdEp6eu=WJkiuiyO8nDVwCHFUuPDbJqU7Kg@mail.gmail.com>
	 <CA+icZUV++2+OG=P1SVbNrpHPLyzrfFX0eu8NHrd0nPjkPDUOtQ@mail.gmail.com>
	 <CA+icZUXpZaHu-FjR6FGnbkG0XEkiukEgYYbDmrSjdqNz4rWCNg@mail.gmail.com>
	 <1375816128.8219.28.camel@jlt4.sipsolutions.net>
	 <CA+icZUXaTYVc_iv3hny6Je9mVdX8KCVpFSNBeukS+Fh-347Wvw@mail.gmail.com>
	 (sfid-20130806_211440_311168_A2CCF549)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	wireless <linux-wireless@vger.kernel.org>, netdev@vger.kernel.org
To: sedat.dilek@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:56221 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653Ab3HFTSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 15:18:47 -0400
In-Reply-To: <CA+icZUXaTYVc_iv3hny6Je9mVdX8KCVpFSNBeukS+Fh-347Wvw@mail.gmail.com> (sfid-20130806_211440_311168_A2CCF549)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-06 at 21:14 +0200, Sedat Dilek wrote:
> On Tue, Aug 6, 2013 at 9:08 PM, Johannes Berg <johannes@sipsolutions.net> wrote:
> > On Tue, 2013-08-06 at 20:35 +0200, Sedat Dilek wrote:
> >
> >> Attached is a diff comparing all new commits in next-20130805.
> >> If one of the commits smells bad to you, please let me know.
> >
> > Out of that list, only the af_packet changes would seem to have any
> > impact on wireless at all.
> >
> 
> git-bisecting... 2 steps to go...
> 
> This one is bad... "af_packet: simplify VLAN frame check in packet_snd"
> 
> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=c483e02614551e44ced3fe6eedda8e36d3277ccc

That seems weird, does reverting it fix it?

johannes
