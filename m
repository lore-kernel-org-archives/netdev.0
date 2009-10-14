From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: Moving drivers into staging (was Re: [GIT PULL] SCSI fixes for
 2.6.32-rc3)
Date: Wed, 14 Oct 2009 19:52:57 +0200
Message-ID: <4AD60FF9.40200@s5r6.in-berlin.de>
References: <1255097287.2934.21.camel@localhost.localdomain> <20091012130652.GB25464@elte.hu> <1255357148.2850.91.camel@localhost.localdomain> <20091012145453.GD4565@elte.hu> <20091012150911.GB1656@suse.de> <20091012154244.GA13323@elte.hu> <20091012232429.GA24254@suse.de> <43e72e890910131108m789110b4hc35e25601ad67bb7@mail.gmail.com> <20091014044519.GA19199@suse.de> <1255497575.1851.16.camel@Joe-Laptop.home> <20091014063308.GE784@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, Greg KH <gregkh@suse.de>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	James Bottomley <James.Bottomley@suse.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Theodore Tso <tytso@mit.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Jing Huang <huangj@brocade.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hp3.statik.tu-cottbus.de ([141.43.120.68]:35203 "EHLO
	hp3.statik.tu-cottbus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402AbZJNRzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 13:55:03 -0400
In-Reply-To: <20091014063308.GE784@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> * Joe Perches <joe@perches.com> wrote:
> 
>> On Tue, 2009-10-13 at 21:45 -0700, Greg KH wrote:
>> > How about when it was scheduled to be removed, we put it in staging and
>> > I'll add it to my announcements about the staging tree every release?
>> > Unless you can think of a better way?
>> 
>> staging/to_be_removed_unless_fixed_by/v.x.y ?
> 
> Yes, that's a real worry. Some time ago i suggested:
> 
>   drivers/staging/good/
>   drivers/staging/bad/
>   drivers/staging/ugly/

How well do "git am", "quilt import" and friends cope with ever changing
directories?

How about using drivers/staging/this_driver/TODO and (or) its Kconfig
help text to leave a note about the plans for this driver?

The worry that these will be ignored like
Documentation/feature-removal-schedule.txt is being ignored may apply to
the path name based solution too, I'm afraid.

(Besides, Greg's release announcements are a good channel for this.
These announcements are actually picked up by the specialized press.)
-- 
Stefan Richter
-=====-==--= =-=- -===-
http://arcgraph.de/sr/
