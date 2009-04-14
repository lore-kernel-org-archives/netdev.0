From: Avi Kivity <avi@redhat.com>
Subject: Re: 2.6.30-rc1 A few issues and a stall
Date: Tue, 14 Apr 2009 15:39:42 +0300
Message-ID: <49E4840E.6010300@redhat.com>
References: <200904121124.07193.edt@aei.ca> <49E45F8E.9080803@redhat.com> <200904140832.25057.edt@aei.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-acpi@vger.kernel.org
To: Ed Tomlinson <edt@aei.ca>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751896AbZDNMjY@vger.kernel.org>
In-Reply-To: <200904140832.25057.edt@aei.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ed Tomlinson wrote:
> On Tuesday 14 April 2009 06:03:58 Avi Kivity wrote:
>   
>> Ed Tomlinson wrote:
>>     
>>> Once the above networking stuff is setup I start kvm with the command below
>>>
>>> QEMU_AUDIO_DRV=alsa kvm -m 1024 -cdrom /mnt/sdc4/divx/archlinux-2009.02-ftp-i686.iso -boot c -smp 3 -usb -usbdevice tablet -vga std -drive file=arch.img -net nic,macaddr=52:54:00:12:34:23 -net tap,ifname=qtap0,script=no -soundhw all -mem-path /hugepages
>>>
>>> which works and the kvm session boots just fine.  
>>>
>>> Issue 2.  When I attempt to ping outside the kvm session the pc (not just the kvm session) hangs.
>>> Its impossible to kill the kvm session and there are numerious info messages from RCU (tree RCU enabled)
>>> about stalls.  
>>>   
>>>       
>> The rcu messages are likely because a processor has died.
>>
>> Do things work if you drop -mem-path?
>>     
>
> It makes no difference.  I did notice that one cpu is peged at 100% though.  I'll be trying
> CONFIG_PROVE_LOCKING tonight for another problem - might give interesting results.
>   

Oh, so this goes away without CONFIG_PROVE_LOCKING?

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.
