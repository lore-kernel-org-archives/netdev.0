From: Steve Modica <modica@sgi.com>
Subject: rudimentary ISR question
Date: Mon, 12 Apr 2004 17:16:39 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <407B1547.5020402@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi All,

I'm looking at the tg3.c driver in the 2.4.21 kernel and in the 
_interrupt routing, the driver is calling spin_lock_irqsave.

Since it's guaranteed that the tg3 interrupt handler will be disabled 
for the duration of the interrupt handler, why can't the driver simply 
call spin_lock?

Steve
