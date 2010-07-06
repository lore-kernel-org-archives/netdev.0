From: Robert Hancock <hancockrwd@gmail.com>
Subject: Re: iwl3945: HARDWARE GONE??
Date: Mon, 05 Jul 2010 18:18:52 -0600
Message-ID: <4C32766C.4080305@gmail.com>
References: <1278086575.2889.8.camel@chi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Priit Laes <plaes@plaes.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1278086575.2889.8.camel@chi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/02/2010 10:02 AM, Priit Laes wrote:
> Heya!
>
> Bumped my kernel to version 2.6.35-rc3-00391-g97e0214 and ran into
> HARDWARE GONE error message..
>
> Hardware is Lenovo x60s and wireless card is intel 3945:
>
> 03:00.0 Network controller: Intel Corporation PRO/Wireless 3945ABG [Golan] Network Connection (rev 02)
> 	Subsystem: Intel Corporation ThinkPad R60e/X60s
> 	Flags: bus master, fast devsel, latency 0, IRQ 47
> 	Memory at edf00000 (32-bit, non-prefetchable) [size=4K]
> 	Capabilities: [c8] Power Management version 2
> 	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
> 	Capabilities: [e0] Express Legacy Endpoint, MSI 00
> 	Capabilities: [100] Advanced Error Reporting
> 	Capabilities: [140] Device Serial Number 00-xx-xx-xx-xx-xx-xx-xx
> 	Kernel driver in use: iwl3945
> 	Kernel modules: iwl3945

Wonder if somehow an ACPI power resource powering the wireless card got 
switched off? What previous kernel version was working, can you try 
bisecting?
