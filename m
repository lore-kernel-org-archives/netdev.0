From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH resend] Renesas Ethernet AVB driver
Date: Sat, 28 Mar 2015 06:17:13 +0100
Message-ID: <55163959.8080101@gmx.de>
References: <2926619.fiYHPz1IBk@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <2926619.fiYHPz1IBk@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 28.03.2015 00:13, Sergei Shtylyov wrote:

> +	spinlock_t lock;		/* Register access lock */

Do you really need one huge lock for all register accesses? Maybe you
should rethink which registers can actually be accessed concurrently and
implement some finer grained locking.

Regards,
Lino
