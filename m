From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [V2 Patch] bonding: move procfs code into bond_procfs.c
Date: Mon, 7 Mar 2011 08:49:50 +0100
Message-ID: <20110307074949.GA2792@psychotron.redhat.com>
References: <1299484726-29905-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1299484726-29905-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Mar 07, 2011 at 08:58:46AM CET, amwang@redhat.com wrote:
>V2: Move #ifdef CONFIG_PROC_FS into bonding.h, as suggested by David.
>
>bond_main.c is bloating, separate the procfs code out,
>move them to bond_procfs.c
>
>Signed-off-by: WANG Cong <amwang@redhat.com>
>
>---
> drivers/net/bonding/Makefile      |    3 +
> drivers/net/bonding/bond_main.c   |  302 +------------------------------------
> drivers/net/bonding/bond_procfs.c |  276 +++++++++++++++++++++++++++++++++
> drivers/net/bonding/bonding.h     |   26 +++
> 4 files changed, 307 insertions(+), 300 deletions(-)
>

Looking good to me

Reviewed-by: Jiri Pirko <jpirko@redhat.com>
