From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 0/8] gianfar: Add support for hibernation
Date: Mon, 12 Oct 2009 20:00:00 +0400
Message-ID: <20091012160000.GA32406@oksana.dev.rtsoft.ru>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Hi all,

Here are few patches that add support for hibernation for gianfar
driver.

Technically, we could just do gfar_close() and then gfar_enet_open()
sequence to restore gianfar functionality after hibernation, but
close/open does so many unneeded things (e.g. BDs buffers freeing and
allocation, IRQ freeing and requesting), that I felt it would be much
better to cleanup and refactor some code to make the hibernation [and
not only hibernation] code a little bit prettier.

Patches on the way...

Thanks,

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
