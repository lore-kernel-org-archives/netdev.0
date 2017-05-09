From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: Re: [PATCH] qca_debug: Reduce function calls for sequence output in
 qcaspi_info_show()
Date: Tue, 9 May 2017 09:07:52 +0200
Message-ID: <290d2473-73bd-70db-b6ef-c50331812f31@i2se.com>
References: <9932ee63-f766-49ce-d760-9a0bd06f0657@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9932ee63-f766-49ce-d760-9a0bd06f0657@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 08.05.2017 um 19:29 schrieb SF Markus Elfring:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Mon, 8 May 2017 19:21:27 +0200
>
> A bit of data was put into a sequence by separate function calls.
> Print the same data together with adjusted seq_printf() calls instead.

Sorry, i'm not happy with this patch. It doesn't increase readabilityand
mixes the output of multiple lines.

The only benefit is a little bit higher performance. But for debugfs
this won't be necessary.

Stefan

>
> This issue was detected by using the Coccinelle software.
>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  drivers/net/ethernet/qualcomm/qca_debug.c | 10 ++--------
>  1 file changed, 2 insertions(+), 8 deletions(-)
>
