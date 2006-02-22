From: Robert Love <rml@novell.com>
Subject: Re: no carrier detection after resume from swsusp (8139too)
Date: Wed, 22 Feb 2006 10:19:59 -0500
Message-ID: <1140621599.6269.10.camel@betsy.boston.ximian.com>
References: <200602212312.23903.nfilus@gmx.net>
	<20060221234947.GA29806@electric-eye.fr.zoreil.com>
	<200602221612.14631.nfilus@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, networkmanager-list@gnome.org,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <networkmanager-list-bounces@gnome.org>
To: Nikolaus Filus <nfilus@gmx.net>
In-Reply-To: <200602221612.14631.nfilus@gmx.net>
List-Unsubscribe: <http://mail.gnome.org/mailman/listinfo/networkmanager-list>,
	<mailto:networkmanager-list-request@gnome.org?subject=unsubscribe>
List-Archive: <http://mail.gnome.org/archives/networkmanager-list>
List-Post: <mailto:networkmanager-list@gnome.org>
List-Help: <mailto:networkmanager-list-request@gnome.org?subject=help>
List-Subscribe: <http://mail.gnome.org/mailman/listinfo/networkmanager-list>,
	<mailto:networkmanager-list-request@gnome.org?subject=subscribe>
Sender: networkmanager-list-bounces@gnome.org
Errors-To: networkmanager-list-bounces@gnome.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-02-22 at 16:12 +0100, Nikolaus Filus wrote:

> I didn't look enough on this issue before.
> 
> After resume, I get "invalid argument" from
> /sys/class/net/eth1/carrier. Reloading the driver *OR* restarting
> networkmanager solves the problem! Is it possible a process like nm blocks 
> some ressources, which are re-initialised by reloading the driver or 
> restarting nm? Notice, that just stopping nm is not enough.
> 
> Thanks in advance,

e100 or e1000?

`carrier' returns EINVAL if the device is not UP.  It might be a bug in
NM if the device is not UP after a resume.  What does `ifconfig eth1`
show before and after a resume?

	Robert Love
