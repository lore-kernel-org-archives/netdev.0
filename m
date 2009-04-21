From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ucc_geth: Move freeing of TX packets to NAPI context
Date: Tue, 21 Apr 2009 02:07:34 -0700 (PDT)
Message-ID: <20090421.020734.195609451.davem@davemloft.net>
References: <20090417220348.GA5429@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leoli@freescale.com, afleming@freescale.com,
	Joakim.Tjernlund@transmode.se, linuxppc-dev@ozlabs.org
To: avorontsov@ru.mvista.com
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090417220348.GA5429@oksana.dev.rtsoft.ru>
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

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Sat, 18 Apr 2009 02:03:48 +0400

> This will make the system alot more responsive while ping flooding the
> ucc_geth ethernet interface.
> 
> Also set NAPI weight to 64 as this is a common value.
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied to net-next-2.6, thank you.
