From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ucc_geth: Move freeing of TX packets to NAPI context.
Date: Mon, 30 Mar 2009 13:36:48 -0700 (PDT)
Message-ID: <20090330.133648.202747210.davem@davemloft.net>
References: <OF6D5FFE1D.1843C7FE-ONC1257589.00328D91-C1257589.00336B8B@transmode.se>
	<2a27d3730903300236j79cc3035raef2bf5e895fe429@mail.gmail.com>
	<OF42785A57.F2F3AFE4-ONC1257589.0035B462-C1257589.003712D0@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, leoli@freescale.com, pku.leo@gmail.com,
	netdev@vger.kernel.org
To: Joakim.Tjernlund@transmode.se
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <OF42785A57.F2F3AFE4-ONC1257589.0035B462-C1257589.003712D0@transmode.se>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Date: Mon, 30 Mar 2009 12:01:33 +0200

> I don't know. But the question you should ask is: Does the networking
> code promise this now and for the future? If not, you should
> fix the driver not to relay on netif_queue_stopped() here.

Stop this nonsense talk.

If the driver can't be the one and only controller of the TX queue
state, everything would essentially explode.

The fact is, it does.
