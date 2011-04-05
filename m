From: Paul Gortmaker <paul.gortmaker@gmail.com>
Subject: Re: [PATCH 29/34] tipc: Drop __TIME__ usage
Date: Tue, 5 Apr 2011 18:25:21 -0400
Message-ID: <BANLkTimxWBC9J5+gDTkZe-J19fkr9vyLcw@mail.gmail.com>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz>
	<1302015561-21047-30-git-send-email-mmarek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: Michal Marek <mmarek@suse.cz>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1302015561-21047-30-git-send-email-mmarek@suse.cz>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 5, 2011 at 10:59 AM, Michal Marek <mmarek@suse.cz> wrote:
> The kernel already prints its build timestamp during boot, no need to
> repeat it in random drivers and produce different object files each
> time.

I'll make sure this gets bundled into the next batch of tipc updates
I proxy to DaveM.   The ccache users should be happier.

Thanks,
Paul.

>
> Cc: Jon Maloy <jon.maloy@ericsson.com>
> Cc: Allan Stephens <allan.stephens@windriver.com>
> Cc: tipc-discussion@lists.sourceforge.net
> Cc: netdev@vger.kernel.org
> Signed-off-by: Michal Marek <mmarek@suse.cz>
> ---
> =A0net/tipc/core.c | =A0 =A03 +--
> =A01 files changed, 1 insertions(+), 2 deletions(-)
>
> diff --git a/net/tipc/core.c b/net/tipc/core.c
> index e071579..33532fe 100644
> --- a/net/tipc/core.c
> +++ b/net/tipc/core.c
> @@ -185,8 +185,7 @@ static int __init tipc_init(void)
> =A0 =A0 =A0 =A0if (tipc_log_resize(CONFIG_TIPC_LOG) !=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0warn("Unable to create log buffer\n");
>
> - =A0 =A0 =A0 info("Activated (version " TIPC_MOD_VER
> - =A0 =A0 =A0 =A0 =A0 =A0" compiled " __DATE__ " " __TIME__ ")\n");
> + =A0 =A0 =A0 info("Activated (version " TIPC_MOD_VER ")\n");
>
> =A0 =A0 =A0 =A0tipc_own_addr =3D 0;
> =A0 =A0 =A0 =A0tipc_remote_management =3D 1;
> --
> 1.7.4.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>
--
To unsubscribe from this list: send the line "unsubscribe linux-kbuild"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
