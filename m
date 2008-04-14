From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 2/2] [POWERPC] UCC nodes cleanup
Date: Mon, 14 Apr 2008 09:59:56 -0500
Message-ID: <45197281-8BDA-4296-9D2C-4663841BD74E@kernel.crashing.org>
References: <20080311171045.GB4684@localhost.localdomain>
	<82E8E38A-C159-4C23-BDE8-086D4429F366@kernel.crashing.org>
	<20080411160654.GA25506@polina.dev.rtsoft.ru>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Jeff Garzik <jgarzik@pobox.com>,
	linux-serial@vger.kernel.org, netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20080411160654.GA25506@polina.dev.rtsoft.ru>
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

> From: Anton Vorontsov <avorontsov@ru.mvista.com>
> Subject: [POWERPC] UCC nodes cleanup
>
> - get rid of `model = "UCC"' in the ucc nodes
>  It isn't used anywhere, so remove it. If we'll ever need something
>  like this, we'll use compatible property instead.
> - replace last occurrences of device-id with cell-index.
>  Drivers are modified for backward compatibility's sake.
>
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> ---
> Documentation/powerpc/booting-without-of.txt |    6 ++----
> arch/powerpc/boot/dts/mpc832x_mds.dts        |    7 +------
> arch/powerpc/boot/dts/mpc832x_rdb.dts        |    4 ----
> arch/powerpc/boot/dts/mpc836x_mds.dts        |    4 ----
> arch/powerpc/boot/dts/mpc8568mds.dts         |    4 ----
> drivers/net/ucc_geth.c                       |    8 +++++++-
> drivers/net/ucc_geth_mii.c                   |   11 ++++++++---
> drivers/serial/ucc_uart.c                    |   16 ++++++++++++----
> 8 files changed, 30 insertions(+), 30 deletions(-)

applied.

- k
