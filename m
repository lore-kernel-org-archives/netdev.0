From: Pavel Belous <pavel.belous@aquantia.com>
Subject: Re: [PATCH][V2] ethernet: aquantia: remove redundant checks on error
 status
Date: Thu, 11 May 2017 23:02:17 +0300
Message-ID: <64e74735-a23e-8b91-7c48-810850f097b7@aquantia.com>
References: <20170511182940.18774-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        "David S . Miller" <davem@davemloft.net>,
        David VomLehn <vomlehn@texas.net>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170511182940.18774-1-colin.king@canonical.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 11.05.2017 21:29, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> The error status err is initialized as zero and then being checked
> several times to see if it is less than zero even when it has not
> been updated.  It may seem that the err should be assigned to the
> return code of the call to the various *offload_en_set calls and
> then we check for failure, however, these functions are void and
> never actually return any status.
>
> Since these error checks are redundant we can remove these
> as well as err and the error exit label err_exit.
>
> Detected by CoverityScan, CID#1398313 and CID#1398306 ("Logically
> dead code")
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: Pavel Belous <pavel.belous@aquantia.com>

Regards,
Pavel
