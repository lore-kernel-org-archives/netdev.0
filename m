From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 12/18]  net/sb1000: replace 	nicedelay() with msleep_interruptible()
Date: Sun, 31 Oct 2004 06:05:15 -0500
Message-ID: <4184C6EB.1000700@pobox.com>
References: <E1CO1w1-0002Uj-Hm@sputnik>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, nacc@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: janitor@sternwelten.at
In-Reply-To: <E1CO1w1-0002Uj-Hm@sputnik>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

janitor@sternwelten.at wrote:
> Any comments would be appreciated.
> 
> Description: Use msleep_interruptible() instead of nicedelay()
> to guarantee the task delays as expected. Remove the prototype and
> definition of nicedelay(). This is a very weird function, because it is
> called to sleep in terms of usecs, but always sleeps for 1 second,
> completely ignoring the parameter. I have gone ahead and followed suit,
> just sleeping for a second in all cases, but maybe someone with the
> hardware could tell me if perhaps the paramter *should* matter.
> Also remove a random "^L" character.

use ssleep() here too
