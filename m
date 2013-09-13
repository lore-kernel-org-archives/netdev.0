From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net 3/3] slcan: rewrite of slc_bump and slc_encaps
Date: Fri, 13 Sep 2013 20:43:12 +0200
Message-ID: <52335CC0.9070400@hartkopp.net>
References: <1379093833-4949-1-git-send-email-nautsch2@gmail.com> <1379093833-4949-4-git-send-email-nautsch2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andre Naujoks <nautsch2@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1379093833-4949-4-git-send-email-nautsch2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13.09.2013 19:37, Andre Naujoks wrote:
> The old implementation was heavy on str* functions and sprintf calls.
> This version is more manual, but faster.
> 
> Profiling just the printing of a 3 char CAN-id resulted in 60 instructions
> for the manual method and over 2000 for the sprintf method. Bear in
> mind the profiling was done against libc and not the kernel sprintf.
> 
> Together with this rewrite an issue with sending and receiving of RTR frames
> has been fixed by Oliver for the cases that the DLC is not zero.
> 
> Signed-off-by: Andre Naujoks <nautsch2@gmail.com>
> Tested-by: Oliver Hartkopp <socketcan@hartkopp.net>
> ---
>  drivers/net/can/slcan.c | 136 +++++++++++++++++++++++++++++++-----------------
>  1 file changed, 87 insertions(+), 49 deletions(-)

As the layout of the generated content is fixed the provided flexibility of
the used string functions was indeed inadequate.

Thanks for the effort, Andre.

Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>
