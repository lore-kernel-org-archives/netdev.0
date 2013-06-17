From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: linux-next: manual merge of the arm-soc tree with the net-next
 tree
Date: Mon, 17 Jun 2013 17:51:29 +0400
Message-ID: <51BF1461.8060401@cogentembedded.com>
References: <20130617163920.04523ba6de50bcc81563f33e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Olof Johansson <olof@lixom.net>, Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Bastian Hecht <hechtb@gmail.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130617163920.04523ba6de50bcc81563f33e@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 17-06-2013 10:39, Stephen Rothwell wrote:

> Today's linux-next merge of the arm-soc tree got a conflict in
> arch/arm/mach-shmobile/clock-r8a7740.c between commit e5c9b4cd6651
> ("sh_eth: get R8A7740 support out of #ifdef") from the net-next tree and
> commit 9e0b428f079d ("ARM: shmobile: r8a7740: Add interim sh-eth device
> name to clocks list") from the arm-soc tree.

    To me that latter commit looked utterly pointless, as there's no 
device tree support for the 'sh-eth' driver yet (and at this stage it 
isn't even going to happen due to procedural platform data). I'm instead 
going to use OF_DEV_AUXDATA() in the platform code which again would 
render that commit pointless.

> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

    Thanks.

WBR, Sergei
