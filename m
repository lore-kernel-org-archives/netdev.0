From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] net: dsa/mv88e6352: make mv88e6352_wait generic
Date: Fri, 23 Jan 2015 17:47:53 -0800
Message-ID: <54C2F9C9.2000404@roeck-us.net>
References: <1422056081-30088-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422056081-30088-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/23/2015 03:34 PM, Vivien Didelot wrote:
> Some busy bits are available in the global register 1, such as the ATU
> Busy bit. We may want to use this function to wait for them to change,
> so add a new parameter to mv88e6352_wait() instead of hard-coding
> REG_GLOBAL2.
>
> In the meantime, since the REG_READ() macro already checks for error,
> remove the redundant check for ret < 0.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Acked-by: Guenter Roeck <linux@roeck-us.net>

Guenter
