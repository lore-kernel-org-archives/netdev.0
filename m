From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 16:58:35 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <40A28FFB.3060000@pobox.com>
References: <20040512020700.6f6aa61f.akpm@osdl.org>	<20040512181903.GG13421@kroah.com>	<40A26FFA.4030701@pobox.com>	<20040512193349.GA14936@elte.hu>	<Pine.LNX.4.58.0405121247011.11950@bigblue.dev.mdolabs.com>	<20040512200305.GA16078@elte.hu>	<20040512132050.6eae6905.akpm@osdl.org>	<20040512203829.GI1397@holomorphy.com> <20040512134718.7e55cceb.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: William Lee Irwin III <wli@holomorphy.com>, mingo@elte.hu,
	davidel@xmailserver.org, greg@kroah.com,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S265230AbUELVB5@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040512134718.7e55cceb.akpm@osdl.org>
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> @@ -187,7 +187,7 @@ static int act200l_change_speed(struct i
>  		/* Write control bytes */
>  		self->write(self->dev, control, 3);
>  		irda_task_next_state(task, IRDA_TASK_WAIT);
> -		ret = MSECS_TO_JIFFIES(5);
> +		ret = MSEC_TO_JIFFIES(5);


Ewww.

Just pluralize the macro, and this patch gets 75% lighter.

	Jeff
