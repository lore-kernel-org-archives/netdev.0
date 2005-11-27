From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: memory allocation for DMA operations from network interface
Date: Sun, 27 Nov 2005 19:19:15 +0100
Message-ID: <1133115556.2853.38.camel@laptopd505.fenrus.org>
References: <aec8d6fc0511271006v265a3537r6a90e7d53f706d26@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751137AbVK0STU@vger.kernel.org>
To: Mateusz Berezecki <mateuszb+lkml@gmail.com>
In-Reply-To: <aec8d6fc0511271006v265a3537r6a90e7d53f706d26@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2005-11-27 at 19:06 +0100, Mateusz Berezecki wrote:
> Hello List,
> 
> My question is about DMA transfers from network device. I suspect
> these transfers require allocating physically contiguous memory 
> blocks. What is the proper way to allocate such contiguous memory for
> DMA purposes inside the kernel? Also what is the proper and
> architecture independent way to convert virtual address to physical
> one?

see Documentation/DMA-mapping.txt
