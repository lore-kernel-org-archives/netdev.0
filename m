From: Chris Metcalf <cmetcalf@ezchip.com>
Subject: Re: [PATCH] tile:Remove unused marcos from the file tilepro.c
Date: Wed, 8 Jul 2015 12:47:22 -0400
Message-ID: <559D541A.5050504@ezchip.com>
References: <1436232151-24185-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436232151-24185-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/06/2015 09:22 PM, Nicholas Krause wrote:
> This removes no longer used marcos at the top of the driver
> due tilepro.c due to having no proper values nor never being
> used by this driver code.
>
> Signed-off-by: Nicholas Krause<xerofoify@gmail.com>
> ---
>   drivers/net/ethernet/tile/tilepro.c | 13 -------------
>   1 file changed, 13 deletions(-)

I'm not sure what you mean by "no longer used".  They are all
potentially usable to enable chunks of code lower down in
the driver, they're just not enabled by default.  So, nack.

Also, "no proper values" doesn't make a lot of sense; if you
specify "#define FOO" it implicitly defines it to the empty
string.  Regardless, it doesn't matter what value it is
defined to if the only uses are "#ifdef", as is true here.

-- 
Chris Metcalf, EZChip Semiconductor
http://www.ezchip.com
