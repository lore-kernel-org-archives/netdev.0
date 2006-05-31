From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: Safe remote kernel install howto (Re: [Bugme-new] [Bug 6613]
   New: iptables broken on 32-bit PReP (ARCH=ppc))
Date: Wed, 31 May 2006 16:25:10 -0400
Message-ID: <447DFBA6.1010607@tmr.com>
References: <200605251004.k4PA4Lek007751@fire-2.osdl.org> <4475FCFC.5000701@trash.net> <Pine.SOC.4.61.0605261008090.14762@math.ut.ee> <200605261429.36078.netdev@axxeo.de> <Pine.SOC.4.61.0605261532140.26383@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel list <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932073AbWEaUXW@vger.kernel.org>
To: Meelis Roos <mroos@linux.ee>
In-Reply-To: <Pine.SOC.4.61.0605261532140.26383@math.ut.ee>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Meelis Roos wrote:
>>> Unfortunatlety, 2.6.15 does not boot on this machine so I'm locked out
>>> remotely at the moment.
>>
>> Here it my paranoid boot setup:
> 
> Thanks, but it's not much use here, since the machine is a PReP powerpc 
> machine that can boot one kernel from disk (directly loaded from boot 
> partition, no fancy bootloader) or netboot via serial console for test 
> kernels. However, if the test kernel hangs, it hangs and I would need 
> remote power cycling device that I do not have.
> 
I did a lot of this at one time, and used lilo in just the way 
described. I did have a remote reboot device, however, an operator (1st 
shift), janitor (2nd shift), or security guard (3rd/wkend shift) who had 
been instructed to push the clearly marked reset button on demand "when 
the weird guy in New York tells you."

IBM rack units, like x345 and such, can have an "RSA" card which allows 
remote hardware monitor and reboot with a separate IP address for 
control. Worth its weight in gold! The latest will let you do remote 
console as well.

-- 
Bill Davidsen <davidsen@tmr.com>
   Obscure bug of 2004: BASH BUFFER OVERFLOW - if bash is being run by a
normal user and is setuid root, with the "vi" line edit mode selected,
and the character set is "big5," an off-by-one errors occurs during
wildcard (glob) expansion.
