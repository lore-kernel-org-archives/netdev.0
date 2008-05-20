From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [Bugme-new] [Bug 10737] New: pktgen procfs problem
Date: Tue, 20 May 2008 10:25:26 +0200
Message-ID: <18482.35574.277447.753735@robur.slu.se>
References: <bug-10737-10286@http.bugzilla.kernel.org/>
	<20080517141036.d8f3c768.akpm@linux-foundation.org>
	<482F88DE.8090508@trash.net>
	<20080517215641.acb94677.akpm@linux-foundation.org>
	<48301BE0.9040907@trash.net>
	<48302E09.8080701@trash.net>
	<48304BB5.7090805@trash.net>
	<1211183642.9966.6.camel@iris.sw.ru>
	<48321AC2.90500@candelatech.com>
	<m1lk257p5k.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	"Denis V. Lunev" <den@openvz.org>,
	Patrick McHardy <kaber@trash.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	devzero@web.de, Robert Olsson <robert.olsson@its.uu.se>,
	Pavel Emelyanov <xemul@openvz.org>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:60958 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761756AbYETIZg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 04:25:36 -0400
In-Reply-To: <m1lk257p5k.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric W. Biederman writes:
 > > Denis V. Lunev wrote:
 > >
 > >> could you consider this preliminary patch? It fixes the problem for me
 > >> and Pavel agrees with it.
 > >>
 > Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

 > >> ------------------------------------------------------------------------
 > >>
 > >> diff --git a/fs/proc/inode.c b/fs/proc/inode.c
 > >> index 6f4e8dc..b08d100 100644
 > >> --- a/fs/proc/inode.c
 > >> +++ b/fs/proc/inode.c
 > >> @@ -425,7 +425,8 @@ struct inode *proc_get_inode(struct super_block *sb,
 > > unsigned int ino,
 > >>  			}
 > >>  		}
 > >>  		unlock_new_inode(inode);
 > >> -	}
 > >> +	} else
 > >> +	       module_put(de->owner);
 > >>  	return inode;
 > >>   out_ino:

 Yes it fixes the oops I got as well.

 Acked-by: Robert Olsson <robert.olsson@its.uu.se>

 Cheers.
					--ro
