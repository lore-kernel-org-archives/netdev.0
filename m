From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: Wireless Extensions WE-18 questions
Date: Mon, 9 Aug 2004 09:41:36 -0700
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Message-ID: <20040809164136.GA17028@bougret.hpl.hp.com>
References: <1091444633.2767.8.camel@rootix> <20040803070843.GB7153@jm.kir.nu>
	<1091929000.2800.12.camel@rootix>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Jouni Malinen <jkmaline@cc.hut.fi>,
	hostap@shmoo.com
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Pedro Ramalhais <ramalhais@serrado.net>
Content-Disposition: inline
In-Reply-To: <1091929000.2800.12.camel@rootix>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://sisyphus.iocaine.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Sun, Aug 08, 2004 at 02:36:40AM +0100, Pedro Ramalhais wrote:
> 
> This one is more oriented to the design of the wireless extensions and
> should probably go to Jean Tourrilhes:
> - the switch/case logic (for set_auth/get_auth at least) should really
> be in the wireless extensions.

	Not everybody is using a wireless card, and of those using
wireless cards, not all of them are using WPA. Therefore, my goal is
to minimise kernel bloat.
	If you don't like the current situation, there are two avenues :
		o use different ioctls
		o use a separate common module to demultiplex the ioctl

> PS: I was hoping someone had already answer my e-mail about the creation
> of a linux wireless mailing list, and this message would be sent to the
> new list... oh well

	Check the archive of netdev mailing list a few months back.

	Have fun...

	Jean
