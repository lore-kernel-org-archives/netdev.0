From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 2/2][Rev4] fs_enet: add MPC5121 FEC support
Date: Fri, 20 Jun 2008 14:50:46 -0500
Message-ID: <485C0A16.6040905@freescale.com>
References: <1213802154-28968-1-git-send-email-jrigby@freescale.com>	<1213802154-28968-2-git-send-email-jrigby@freescale.com>
	<1213802154-28968-3-git-send-email-jrigby@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Sam Ravnborg <sam@ravnborg.org>, jeff@garzik.org,
	netdev@vger.kernel.org
To: John Rigby <jrigby@freescale.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1213802154-28968-3-git-send-email-jrigby@freescale.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

John Rigby wrote:
> +       select PPC_CPM_NEW_BINDING if PPC_MPC512x

Don't bother with this.  It's always selected on arch/powerpc -- and now 
that arch/ppc is gone, there are patches floating around to remove the 
ifdefs.

-Scott
