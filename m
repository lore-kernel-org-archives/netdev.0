From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Thu, 3 Jul 2008 12:10:02 -0400
Message-ID: <B8CBA141-D78E-4EEF-92C4-9CF7184E6C7F@oracle.com>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org> <20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, LKML Kernel <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-next@vger.kernel.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Jul 3, 2008, at 7:59 AM, KOSAKI Motohiro wrote:
> Hi Michael,
>
> my server output following error message on 2.6.26-rc8-mm1.
> Is this a bug?
>
> ------------------------------------------------------------------
> tg3.c:v3.93 (May 22, 2008)
> GSI 72 (level, low) -> CPU 0 (0x0001) vector 51
> tg3 0000:06:01.0: PCI INT A -> GSI 72 (level, low) -> IRQ 51
> firmware: requesting tigon/tg3_tso.bin
> tg3: Failed to load firmware "tigon/tg3_tso.bin"
> tg3 0000:06:01.0: PCI INT A disabled
> GSI 72 (level, low) -> CPU 0 (0x0001) vector 51 unregistered
> tg3: probe of 0000:06:01.0 failed with error -2
> GSI 73 (level, low) -> CPU 0 (0x0001) vector 51
> tg3 0000:06:01.1: PCI INT B -> GSI 73 (level, low) -> IRQ 52
> firmware: requesting tigon/tg3_tso.bin

Same problem here with linux-next on a Dell Latitude D620.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
