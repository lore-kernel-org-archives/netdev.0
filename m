From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: Re: 802.15.4 Issues
Date: Tue, 31 Jul 2012 22:40:52 -0400
Message-ID: <50189734.7060406@signal11.us>
References: <50180217.8040706@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <50180217.8040706-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/31/2012 12:04 PM, Alan Ott wrote:
> I'm trying to follow the directions at linux-wsn[1] and am not having
> much luck. Since I don't have the at91sam9g20ek board, I'm trying this
> on my desktop PC with an Econotag[2] (using the serial.c driver I pulled
> from [3]) and on a BeagleBone with an MRF24J40 (using a driver I made [4]).

> Like I said, I feel like there's something fundamental I'm doing wrong.

There was....
If you don't run izcoordinator with -d, it won't set the PAN and/or
short address.

    izcoordinator -i wpan0 -d 1 -s 2 -p 777 -c 11 -l lease

This should go in the instructions at [1]. Alexander, if you give me
permissions I'll fix it.

While we're on instructions... :
    "insmod iz listphy" (remove insmod)


Now to figure out why my ping doesn't work....

Alan.

> [1] http://code.google.com/p/linux-wsn/wiki/Mainline
> [2] http://www.redwirellc.com/store/node/1
> [3]
> http://linux-zigbee.git.sourceforge.net/git/gitweb.cgi?p=linux-zigbee/kernel;a=summary
> [4] http://permalink.gmane.org/gmane.linux.network.zigbee.devel/1135
> [5] http://sourceforge.net/apps/trac/linux-zigbee/wiki/GettingStarted-0.2


------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
