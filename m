From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 13/18]  net/cycx_drv: replace 	delay_cycx() with msleep_interruptible()
Date: Sun, 31 Oct 2004 06:04:07 -0500
Message-ID: <4184C6A7.7060400@pobox.com>
References: <E1CO1w4-0002YG-VR@sputnik>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, nacc@us.ibm.com, acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: janitor@sternwelten.at
In-Reply-To: <E1CO1w4-0002YG-VR@sputnik>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

janitor@sternwelten.at wrote:
> -/* Delay */
> -static void delay_cycx(int sec)
> -{
> -	set_current_state(TASK_INTERRUPTIBLE);
> -	schedule_timeout(sec * HZ);
> -}


this _clearly_ wants an ssleep() derivative, not msleep()

	Jeff
