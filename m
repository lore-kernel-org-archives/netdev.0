From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 05/18]  net/s2io: replace 	schedule_timeout() with msleep()
Date: Sun, 31 Oct 2004 06:09:34 -0500
Message-ID: <4184C7EE.5070107@pobox.com>
References: <E1CO1vc-00022t-N2@sputnik>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, nacc@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: janitor@sternwelten.at
In-Reply-To: <E1CO1vc-00022t-N2@sputnik>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

janitor@sternwelten.at wrote:
> @@ -2846,11 +2838,10 @@ static int s2io_ethtool_idnic(struct net
>  		sp->id_timer.data = (unsigned long) sp;
>  	}
>  	mod_timer(&sp->id_timer, jiffies);
> -	set_current_state(TASK_INTERRUPTIBLE);
>  	if (data)
> -		schedule_timeout(data * HZ);
> +		msleep_interruptible(data * 1000);


clearly wants ssleep() here
