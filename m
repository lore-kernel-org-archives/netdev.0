From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: powerpc allmodconfig
Date: Thu, 16 Oct 2008 13:02:37 -0700
Message-ID: <20081016130237.4984967c@infradead.org>
References: <20081015213337.a99a9595.akpm@linux-foundation.org>
	<20081015.220247.262683261.davem@davemloft.net>
	<1224169039.735.57.camel@johannes.berg>
	<20081016.124923.222595655.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, akpm@linux-foundation.org,
	dan.j.williams@intel.com, tiwai@suse.de,
	linux-ext4@vger.kernel.org, netdev@vger.kernel.org,
	linux-ide@vger.kernel.org, bzolnier@gmail.com,
	marek.vasut@gmail.com, dwmw2@infradead.org, mark.fasheh@oracle.com,
	ralf@linux-mips.org, mchehab@infradead.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20081016.124923.222595655.davem@davemloft.net>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Oct 2008 12:49:23 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:
> #endif
> #define __WARN() warn_on_slowpath(__FILE__, __LINE__)
> #define __WARN_printf(arg...) warn_slowpath(__FILE__, __LINE__, arg)
> #else
> #define __WARN_printf(arg...) __WARN()

the easiest way I suppose would be to do

#define __WARN_printf(arg..) do { printk(arg); __WARN(); } while (0)

any obvious problems with this ?


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
