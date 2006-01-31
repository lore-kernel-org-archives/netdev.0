From: Knut Petersen <Knut_Petersen@t-online.de>
Subject: Re: [BUG] 8139too fails for ip autoconfig and nfsroot
Date: Tue, 31 Jan 2006 12:03:58 +0100
Message-ID: <43DF441E.4040304@t-online.de>
References: <43DE7035.1040806@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750756AbWAaLFw@vger.kernel.org>
To: linux-kernel@vger.kernel.org
In-Reply-To: <43DE7035.1040806@t-online.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Knut Petersen wrote:

> but found none. Skipping ip autoconfig is no solution, the kernel then 
> fails trying rpc lookup.
>
> Then I tried to netboot another system with the same kernel + via 
> rhine driver, same server
> config. Voila, dhcp ip autoconfig and rpc port lookup is not a problem 
> on this system.
>
> During my search for a solution I tried some recent kernels, the 
> oldest 2.6.14. All fail with 8139too.
>
> Any ideas?
>
It does work now. How?

I enabled  "Use PIO instead of MMIO". Everything started to work.
I disabled "Use PIO instead of MMIO" and enabled "Use older RX-reset 
method".
Everything still fine.

The crazy thing is that it does work now even with both of the options 
disabled.
It does work even after complete power removal for several hours.

cu,
 Knut
