From: Jens Axboe <axboe@kernel.dk>
Subject: Re: [PATCH 13/31] timer: Remove meaningless .data/.function
 assignments
Date: Fri, 1 Sep 2017 14:07:32 -0600
Message-ID: <a0462e18-5eae-95e0-21af-e9709729abb1@kernel.dk>
References: <1504222183-61202-1-git-send-email-keescook@chromium.org>
 <1504222183-61202-14-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Halasa <khc@pm.waw.pl>,
        Aditya Shankar <aditya.shankar@microchip.com>,
        Ganesh Krishna <ganesh.krishna@microchip.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
        devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>,
        Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504222183-61202-14-git-send-email-keescook@chromium.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/31/2017 05:29 PM, Kees Cook wrote:
> Several timer users needlessly reset their .function/.data fields during
> their timer callback, but nothing else changes them. Some users do not
> use their .data field at all. Each instance is removed here.

For amiflop:

Acked-by: Jens Axboe <axboe@kernel.dk>

-- 
Jens Axboe
