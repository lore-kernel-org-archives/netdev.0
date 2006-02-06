From: Dan Williams <dcbw@redhat.com>
Subject: Re: [test] airo : first WPA-PSK support
Date: Mon, 06 Feb 2006 14:01:57 -0500
Message-ID: <1139252518.5831.14.camel@dhcp83-115.boston.redhat.com>
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

Also, do you have access to the 4500/4800 Developer's Manual?  I'm
curious what the status code 0x0600 for an EV_LINK event is (as seen in
airo_interrupt()).

#define AUTHFAIL 0x0300 /* Authentication failure (low byte is reason
			   code) */
#define ASSOCIATED 0x0400 /* Assocatied */

There's 0x400, but no 0x0200 which is what I'd expect is the case for a
status code of 0x0600 (ie 0x0400 + 0x0200).

Thanks!
Dan
