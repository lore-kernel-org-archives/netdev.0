From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH 0/7] fs_enet patches
Date: Fri, 17 Aug 2007 12:53:20 -0500
Message-ID: <20070817175320.GA8259@ld0162-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

The following patchset includes several updates for the fs_enet driver,
the most prominent being conversion to an of_platform device (with
platform_device code remaining until arch/ppc goes away).  It also
includes a generic MDIO bitbang library, and converts fs_enet to use it.

I have a powerpc patch (ep8248e board support) that depends on the MDIO
bitbang library, so it may be better to ack them for Paul to pick up --
but if not, I can postpone the ep8248e patch until the merge window.

-Scott
