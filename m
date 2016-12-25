From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 2/2] drivers: net: ethernet: 3com: fix return value
Date: Sun, 25 Dec 2016 13:07:17 +0300
Message-ID: <c11460ea-1fd6-0a1a-9a56-ade5216663db@cogentembedded.com>
References: <4200be74-f7e7-db6b-a258-8fd178fef369@cogentembedded.com>
 <1482625822-19658-1-git-send-email-thomas.preisner+linux@fau.de>
 <1482625822-19658-3-git-send-email-thomas.preisner+linux@fau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dave@thedillows.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-kernel@i4.cs.fau.de,
        milan.stephan+linux@fau.de
To: Thomas Preisner <thomas.preisner+linux@fau.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482625822-19658-3-git-send-email-thomas.preisner+linux@fau.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 12/25/2016 3:30 AM, Thomas Preisner wrote:

> In some cases the return value of a failing function is not being used
> and the function typhoon_init_one() returns another negative error
> code instead.
>
> Signed-off-by: Thomas Preisner <thomas.preisner+linux@fau.de>
> Signed-off-by: Milan Stephan <milan.stephan+linux@fau.de>
> ---
>  drivers/net/ethernet/3com/typhoon.c | 16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)

    In addition to what DaveM said, your choise of the subject prefixes is too 
wide -- it would seem that you're fixing all 3com drivers, while you're only 
fixing typhoon. That "typhoon:" alone would have been an appropriate prefix.

MBR, Sergei
