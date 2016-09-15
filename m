From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH] mwifiex: fix null pointer deference when adapter is null
Date: Thu, 15 Sep 2016 23:56:38 +1000
Message-ID: <CAGRGNgVAWa8OK_qWkDapzy2L8oUhrXYCCfVYhrwWQc9F22vhVw@mail.gmail.com>
References: <20160915134238.5167-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amitkumar Karwar <akarwar@marvell.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160915134238.5167-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

On Thu, Sep 15, 2016 at 11:42 PM, Colin King <colin.king@canonical.com> wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> If adapter is null the error exit path in mwifiex_shutdown_sw is
> to down the semaphore sem and print some debug via mwifiex_dbg.
> However, passing a NULL adapter to mwifiex_dbg causes a null
> pointer deference when accessing adapter->dev.  This fix checks
> for a null adapter at the start of the function and to exit
> without the need to up the semaphore and we also skip the debug
> to avoid the null pointer dereference.
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
