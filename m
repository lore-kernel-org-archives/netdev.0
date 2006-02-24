From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [git patches] net driver fixes
Date: Fri, 24 Feb 2006 08:14:09 -0800
Message-ID: <43FF30D1.8060708@osdl.org>
References: <20060224052214.GA14586@havoc.gtf.org> <200602240859.23062.woho@woho.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Andrew Morton <akpm@osdl.org>,
	Linus Torvalds <torvalds@osdl.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932296AbWBXQOX@vger.kernel.org>
To: woho@woho.de
In-Reply-To: <200602240859.23062.woho@woho.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wolfgang Hoffmann wrote:
> On Friday 24 February 2006 06:22, Jeff Garzik wrote:
>   
>> Please pull from 'upstream-fixes' branch of
>> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
>>
>> [...]
>> Stephen Hemminger:
>>       sky2: yukon-ec-u chipset initialization
>>       sky2: limit coalescing values to ring size
>>       sky2: poke coalescing timer to fix hang
>>       sky2: force early transmit status
>>       sky2: use device iomem to access PCI config
>>       sky2: close race on IRQ mask update.
>> [...]
>>     
>
> Thanks for the update.
>
> Still I'm seeing reproducable hangs with this version of sky2 (as reported in 
> bugzilla 6084 and discussed on netdev).
>
> Stephen, if there is anything I can do to narrow down my hangs a bit more 
> systematically, please let me know, I'd be happy to help.
>
> Wolfgang
>   
There is an outstanding bug where the sky2 will hang if it receives a 
packet larger than the
MTU.  At this point, there isn't enough information on chip behavior to fix.

You could try using a larger mut or patching the driver so that the 
rx_buffer_size is always big (like 4k).
