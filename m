From: Anton Vorontsov <cbouatmailru@gmail.com>
Subject: Re: [PATCH] gianfar: Revive the driver for eTSEC devices (disable
	timestamping)
Date: Thu, 10 Jun 2010 14:41:32 +0400
Message-ID: <20100610104132.GA16174@oksana.dev.rtsoft.ru>
References: <20100609193219.GA8629@oksana.dev.rtsoft.ru>
	<20100610062907.GA3390@riccoc20.at.omicron.at>
	<20100610093159.GA30822@oksana.dev.rtsoft.ru>
	<20100610102226.GA10653@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Manfred Rudigier <Manfred.Rudigier@omicron.at>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20100610102226.GA10653@riccoc20.at.omicron.at>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 10, 2010 at 12:22:26PM +0200, Richard Cochran wrote:
[...]
> > U-Boot 1.1.6 (Oct  9 2007 - 20:42:39) MPC83XX
> ...
> > CPU: MPC8313E, Rev: 10 at 333.333 MHz
> 
> We have a newer CPU revision:
> 
>    U-Boot 1.3.0 (Dec 23 2008 - 13:38:14) MPC83XX
>    CPU:   e300c3, MPC8313E, Rev: 21 at 333.333 MHz, CSB:  166 MHz
> 
> Perhaps a bug was fixed between revision 10 and 21...
> 
> You mentioned having trouble on the MPC8568EMDS. Was it the same
> problem?

Yep, the symptomps were exactly the same, it didn't want to get
the DHCP answer, while I saw the DHCP requests on the host side.

But I don't know if disabling the timestamping fixes 8568, maybe
there is some additional problem with it, no idea as I don't have
8568 board in my hands any longer. I can try any proposed fixes
as soon as I get it back though.

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
