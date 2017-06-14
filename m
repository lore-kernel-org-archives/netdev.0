From: Tony Lindgren <tony@atomide.com>
Subject: Re: [RFC/RFT PATCH 4/4] [debug] ARM: am335x: illustrate hwstamp
Date: Tue, 13 Jun 2017 22:38:27 -0700
Message-ID: <20170614053827.GD3730@atomide.com>
References: <20170613231623.28353-1-grygorii.strashko@ti.com>
 <20170613231623.28353-5-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Sekhar Nori <nsekhar@ti.com>,
        Richard Cochran <richardcochran@gmail.com>,
        linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
        ivan.khoronzhuk@linaro.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:51628 "EHLO muru.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750745AbdFNFib (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 01:38:31 -0400
Content-Disposition: inline
In-Reply-To: <20170613231623.28353-5-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Grygorii Strashko <grygorii.strashko@ti.com> [170613 16:20]:
> This patch allows to test CPTS HW_TS_PUSH functionality on am335x boards
> 
> below sequence of commands will enable Timer7 to trigger 1sec
> periodic pulses on CPTS HW4_TS_PUSH input pin:
> 
>  # echo 1000000000 > /sys/class/pwm/pwmchip0/pwm0/period
>  # echo 500000000 > /sys/class/pwm/pwmchip0/pwm0/duty_cycle
>  # echo 1 > /sys/class/pwm/pwmchip0/pwm0/enable
>  # ./ptp/testptp -e 10 -i 3
> external time stamp request okay
> event index 3 at 1493259028.376600798
> event index 3 at 1493259029.377170898
> event index 3 at 1493259030.377741039
> event index 3 at 1493259031.378311139
> event index 3 at 1493259032.378881279
> event index 3 at 1493259033.379451424
> event index 3 at 1493259034.380021520
> event index 3 at 1493259035.380591660
> event index 3 at 1493259036.381161765
> event index 3 at 1493259037.381731909

Cool :)

Acked-by: Tony Lindgren <tony@atomide.com>
