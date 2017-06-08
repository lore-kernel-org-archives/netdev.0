From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] mwifiex: Replace semaphore async_sem with mutex
Date: Thu, 8 Jun 2017 16:58:12 +0200
Message-ID: <CAK8P3a2kJbXX8ROBgqyQDpwpKZPm_rNWW_oOAjOJyM7C-DZTiw@mail.gmail.com>
References: <1496916183-4097-1-git-send-email-binoy.jayan@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Rajendra <rnayak@codeaurora.org>,
        Mark Brown <broonie@kernel.org>,
        Amitkumar Karwar <amitkarwar@gmail.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Xinming Hu <huxm@marvell.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>
To: Binoy Jayan <binoy.jayan@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496916183-4097-1-git-send-email-binoy.jayan@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 8, 2017 at 12:03 PM, Binoy Jayan <binoy.jayan@linaro.org> wrote:
> The semaphore 'async_sem' is used as a simple mutex, so
> it should be written as one. Semaphores are going away in the future.
>
> Signed-off-by: Binoy Jayan <binoy.jayan@linaro.org>
> ---
>
> This patch is part of a bigger effort to eliminate unwanted
> semaphores from the linux kernel.

Looks good,

Reviewed-by: Arnd Bergmann <arnd@arndb.de>
