From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: Re: [PATCH] davinci_emac.c: Fix IFF_ALLMULTI setup
Date: Tue, 22 Oct 2013 08:04:39 +0530
Message-ID: <CA+V-a8ud7PJXRH-cLkj2YknkKaFy2XZOh4yPjc2yhk1+M1twTQ@mail.gmail.com>
References: <5265640C.4070201@cogentembedded.com> <1382377504-24688-1-git-send-email-mceier+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Jingoo Han <jg1.han@samsung.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Mariusz Ceier <mceier+kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382377504-24688-1-git-send-email-mceier+kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Mariusz,

On Mon, Oct 21, 2013 at 11:15 PM, Mariusz Ceier <mceier+kernel@gmail.com> wrote:
> When IFF_ALLMULTI flag is set on interface and IFF_PROMISC isn't,
> emac_dev_mcast_set should only enable RX of multicasts and reset
> MACHASH registers.
>
> It does this, but afterwards it either sets up multicast MACs
> filtering or disables RX of multicasts and resets MACHASH registers
> again, rendering IFF_ALLMULTI flag useless.
>
> This patch fixes emac_dev_mcast_set, so that multicast MACs filtering and
> disabling of RX of multicasts are skipped when IFF_ALLMULTI flag is set.
>
> Tested with kernel 2.6.37.
>
It would have been better if you would have tested this on the latest kernel.
Anyway David has pulled this patch in his tree.

Regards,
--Prabhakar Lad
