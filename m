From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] wil6210: Replace five seq_puts() calls by seq_putc()
Date: Tue, 09 May 2017 05:25:23 -0700
Message-ID: <1494332723.7796.74.camel@edumazet-glaptop3.roam.corp.google.com>
References: <64747f85-e373-a0ff-b6dc-70cdfe35f71a@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: wil6210@qca.qualcomm.com, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
        Maya Erez <qca_merez@qca.qualcomm.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <64747f85-e373-a0ff-b6dc-70cdfe35f71a@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-05-09 at 09:50 +0200, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Mon, 8 May 2017 22:22:04 +0200
> 
> Five single characters (line breaks) should be put into a sequence.
> Thus use the corresponding function "seq_putc".
> 
> This issue was detected by using the Coccinelle software.

There is no _issue_ at all here, only a matter of taste.

printf("\n")  or putchar('\n')  in some slow path is really not that
interesting.
