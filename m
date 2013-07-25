From: Prashant Shah <pshah.mumbai@gmail.com>
Subject: Re: [PATCH] Change request_irq() to use struct net_device *dev->name
Date: Thu, 25 Jul 2013 11:08:37 +0530
Message-ID: <CAD6i1f+NYu7rcQwF-TXk4+OdjPNZwMKxxjJ9YA_+v9B6uPYq+g@mail.gmail.com>
References: <1374646199-9398-1-git-send-email-pshah.mumbai@gmail.com>
	<51F07489.7010404@gmail.com>
	<CAD6i1fJO3geZ0vkHLsJEd+KedHkpC1OZVTJJskU2RAAKYBhhJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernel-mentors@selenic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ryan Mallon <rmallon@gmail.com>
Return-path: <kernel-mentors-bounces@selenic.com>
In-Reply-To: <CAD6i1fJO3geZ0vkHLsJEd+KedHkpC1OZVTJJskU2RAAKYBhhJQ@mail.gmail.com>
List-Unsubscribe: <http://selenic.com/mailman/options/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=unsubscribe>
List-Archive: <http://selenic.com/pipermail/kernel-mentors>
List-Post: <mailto:kernel-mentors@selenic.com>
List-Help: <mailto:kernel-mentors-request@selenic.com?subject=help>
List-Subscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=subscribe>
Sender: kernel-mentors-bounces@selenic.com
Errors-To: kernel-mentors-bounces@selenic.com
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Jul 25, 2013 at 10:49 AM, Prashant Shah <pshah.mumbai@gmail.com> wrote:
> Hi,
>
>> You should also remove the definition of DRV_NAME, since it is no longer
>> used. The changelog should probably mention that this will change the
>> interrupt name (which appears in /proc/interrupts for example) from "wd"
>> to "eth%d".
>>

I was going through the code. The apne driver apne.c in the same
folder is using DRV_NAME in request_region()

> if (!request_region(IOBASE, 0x20, DRV_NAME)) {

I can change the wd.c request_region() code to use DRV_NAME. Currently
it is using a string constant.

> r = request_region(base_addr, WD_IO_EXTENT, "wd-probe");

This will make it more consistent. Please suggest which change is more
preferable.

@Matthew, following drivers are not using dev->name in request_irq()
axnet_cs.c
mac8390.c
hydra.c
ne-h8300.c
apne.c
stnic.c
zorro8390.c

Regards.
