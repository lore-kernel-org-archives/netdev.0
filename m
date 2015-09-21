From: Manoil Claudiu <claudiu.manoil@freescale.com>
Subject: RE: [PATCH 13/17] net: gianfar: remove misuse of IRQF_NO_SUSPEND flag
Date: Mon, 21 Sep 2015 16:24:15 +0000
Message-ID: <BY2PR0301MB072700F43F00CFC273FED1B59C460@BY2PR0301MB0727.namprd03.prod.outlook.com>
References: <1442850433-5903-1-git-send-email-sudeep.holla@arm.com>
 <1442850433-5903-14-git-send-email-sudeep.holla@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Thomas Gleixner <tglx@linutronix.de>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	"David S. Miller" <davem@davemloft.net>,
	Kevin Hao <haokexin@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sudeep Holla <sudeep.holla@arm.com>,
	"linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442850433-5903-14-git-send-email-sudeep.holla@arm.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Sudeep Holla [mailto:sudeep.holla@arm.com]
>Sent: Monday, September 21, 2015 6:47 PM
>To: linux-pm@vger.kernel.org; linux-kernel@vger.kernel.org
>Cc: Sudeep Holla <sudeep.holla@arm.com>; Thomas Gleixner
><tglx@linutronix.de>; Rafael J. Wysocki <rjw@rjwysocki.net>; David S. Miller
><davem@davemloft.net>; Manoil Claudiu-B08782
><claudiu.manoil@freescale.com>; Kevin Hao <haokexin@gmail.com>;
>netdev@vger.kernel.org
>Subject: [PATCH 13/17] net: gianfar: remove misuse of IRQF_NO_SUSPEND
>flag
>
>The device is set as wakeup capable using proper wakeup API but the
>driver misuses IRQF_NO_SUSPEND to set the interrupt as wakeup source
>which is incorrect.
>
>This patch removes the use of IRQF_NO_SUSPEND flags replacing it with
>enable_irq_wake instead.
>

What would be the purpose of IRQF_NO_SUSPEND flag then?  The flag is a
friendlier API compared to calling enable_irq_wake().  For older kernels,
on PPC architectures, the flag did the job.  When did this change? Since
when using IRQF_NO_SUSPEND is a "misuse"?

Thanks,
Claudiu
