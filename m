From: Dan Williams <dcbw@redhat.com>
Subject: Re: [test] airo : first WPA-PSK support
Date: Mon, 06 Feb 2006 16:56:29 -0500
Message-ID: <1139262989.7569.1.camel@dhcp83-115.boston.redhat.com>
References: <4369099D.3010502@free.fr>  <43E7902E.9080002@free.fr>
	<1139251955.5831.9.camel@dhcp83-115.boston.redhat.com>
	<43E7B036.80202@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hostap@shmoo.com
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: matthieu castet <castet.matthieu@free.fr>
In-Reply-To: <43E7B036.80202@free.fr>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://lists.shmoo.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Mon, 2006-02-06 at 21:23 +0100, matthieu castet wrote:
> Hi,
> 
> Dan Williams wrote:
> > I can help out with the mpi350 if you'd like.  However, most of the code
> > for the MPI350 should be exactly the same as with the PCMCIA version of
> > the card.  They share just about everything except for the bus type.
> > (unless I'm wrong?)
> There are some differences for RX and TX code. Search for FLAG_MPI. But 
> this should'nt be really hard to add them.
> I will try to add it this weekend.
> 
> 
> > 
> > I think bits of this patch (at least the support for the WPA & RSN
> > information elements in scans) should be upstreamed as soon as possible,
> I don't know if you know well the code, but the driver can read/write 
> some data that are indexed with RID.
> The main problem is that in order to use WPA, you need to used RID 
> supported only by newer firmware.
> For example for WPA & RSN in scan you need to use a newer RID and a 
> modified struct for data storage.
> But the RID for configuration didn't change with newer firmware but 
> there are extra elements in the structure.

AFAIK anything less than 5.40.x doesn't work anyway.  The latest stuff
(5.60.x) has worked fine.  I previously had 5.30.17, which tended to
hang the card after a while.  Anyway, perhaps we require people to
update their firmware.  Not sure.

What's the minimum firmware version for WPA support?

Dan
