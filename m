From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [Bonding-devel] [PATCH 4/4] bonding: add sysfs files to
	display tlb and alb hash table contents
Date: Mon, 28 Sep 2009 21:37:13 -0400
Message-ID: <20090929013713.GG4436@gospo.rdu.redhat.com>
References: <20090911211317.GT8515@gospo.rdu.redhat.com> <20090928162237.6db0c9f5@nehalam> <20090929001203.GE4436@gospo.rdu.redhat.com> <20090928173420.07e9dfad@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22327 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753858AbZI2BhZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2009 21:37:25 -0400
Content-Disposition: inline
In-Reply-To: <20090928173420.07e9dfad@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 28, 2009 at 05:34:20PM -0700, Stephen Hemminger wrote:
> On Mon, 28 Sep 2009 20:12:03 -0400
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> > On Mon, Sep 28, 2009 at 04:22:37PM -0700, Stephen Hemminger wrote:
> > > On Fri, 11 Sep 2009 17:13:17 -0400
> > > Andy Gospodarek <andy@greyhouse.net> wrote:
> > > 
> > > > 
> > > > bonding: add sysfs files to display tlb and alb hash table contents
> > > > 
> > > > While debugging some problems with alb (mode 6) bonding I realized that
> > > > being able to output the contents of both hash tables would be helpful.
> > > > This is what the output looks like for the two files:
> > > > 
> > > > device  load
> > > > eth1    491
> > > > eth2    491
> > > > hash device   last device   tx bytes       load        next previous
> > > > 2    eth1     eth1          2254           491         0    0
> > > > 3    eth2     eth2          2744           491         0    0
> > > > 6             eth2          0              488         0    0
> > > > 8             eth2          0              461698      0    0
> > > > 1b            eth2          0              249         0    0
> > > > eb            eth2          0              21          0    0
> > > > ff            eth2          0              22          0    0
> > > > 
> > > > hash ip_src          ip_dst          mac_dst           slave assign ntt
> > > > 2    10.0.3.2        10.0.3.11       00:e0:81:71:ee:a9 eth1  1      0
> > > > 3    10.0.3.2        10.0.3.10       00:e0:81:71:ee:a9 eth2  1      0
> > > > 8    10.0.3.2        10.0.3.1        00:e0:81:71:ee:a9 eth2  1      0
> > > > 
> > > > These were a great help debugging the fixes I have just posted and they
> > > > might be helpful for others, so I decided to include them in my
> > > > patchset.
> > > > 
> > > > Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> > > 
> > > No.
> > > 
> > > Please don't put formatted output in sysfs, it is not meant to be
> > > used like proc, there is supposed to be only one value per file.
> > 
> > Then based on the over 300 files in /sys/ that are more than 1 line on
> > my currently running kernel, it seems there is significant work to do.
> > 
> > Seemingly arbitrary requests like this are extremely annoying when the
> > current kernel violates them all over the place.
> > 
> 
> The rules are documented in Documentation/sysfs-rules.txt. If you want
> to change the rules, submit a change to the rules.
> 

That specific request is actually in filesystems/sysfs.txt in the
'Attributes' section, but the fact that it's actually outlined somewhere
makes the request seem less 'arbitrary.'  ;-)

