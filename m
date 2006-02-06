From: Dan Williams <dcbw@redhat.com>
Subject: Re: [test] airo : first WPA-PSK support
Date: Mon, 06 Feb 2006 13:52:34 -0500
Message-ID: <1139251955.5831.9.camel@dhcp83-115.boston.redhat.com>
References: <4369099D.3010502@free.fr>  <43E7902E.9080002@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hostap@shmoo.com
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: matthieu castet <castet.matthieu@free.fr>
In-Reply-To: <43E7902E.9080002@free.fr>
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

On Mon, 2006-02-06 at 19:06 +0100, matthieu castet wrote:
> Hi,
> 
> matthieu castet wrote:
> > Hi,
> > 
> > I have a working linux airo driver that support  WPA-PSK, but it is very 
> > ugly.
> > It only support one card, and don't support MPI350. Also it only works 
> > with WPA.
> > 
> > Currently the RX and TX key are set only for set_tx=1 key. The card 
> > should report valid mic key with EV_MIC, but the driver hangs for an 
> > unknow reason.
> > 
> > There still lot's of work to complete WPA support and merge it with an 
> > universal driver.
> > 
> > Attached a diff against 2.6.14 kernel.
> > 
> Some people asks me the status of this patch. The last version is 
> available at http://castet.matthieu.free.fr/airo/ .
> As I haven't any MPI350 it is still not supported and because only few 
> people seem interested in this driver I don't plan to clean it for 
> kernel.org integration.

I can help out with the mpi350 if you'd like.  However, most of the code
for the MPI350 should be exactly the same as with the PCMCIA version of
the card.  They share just about everything except for the bus type.
(unless I'm wrong?)

Note that I added ENCODEEXT and AUTH support (for WEP only of course) in
a previous kernel patch, so you'll likely have to rediff your patches
against that...

I think bits of this patch (at least the support for the WPA & RSN
information elements in scans) should be upstreamed as soon as possible,
I'm willing to help with that too.

Dan
