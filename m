From: "George Georgalis" <george@galis.org>
Subject: Re: kernel-2.6.8.1 EIP is at velocity_netdev_event+0x16/0x50
Date: Sun, 15 Aug 2004 15:21:55 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040815192155.GG32195@trot.local>
References: <20040815095814.GA32195@trot.local> <20040815110625.GA2829@electric-eye.fr.zoreil.com> <20040815155457.GB32195@trot.local> <20040815184937.GA9105@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	alan@lxorguk.ukuu.org.uk
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S266851AbUHOTWA@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20040815184937.GA9105@electric-eye.fr.zoreil.com>
List-Id: netdev.vger.kernel.org

On Sun, Aug 15, 2004 at 08:49:38PM +0200, Francois Romieu wrote:
>George Georgalis <george@galis.org> :
>[...]
>> ...that patch doesn't build
>> 
>>   26674 Aug 15 06:51 ../20040815-2.6.8-via-velocity-test.patch
>
>The patch has been updated. Same location.

still no build...

kernel-2.6.8.1 +
   27253 Aug 15 14:31 ../20040815-2.6.8-via-velocity-test.patch


  CC      arch/i386/pci/i386.o
  CC      arch/i386/pci/pcbios.o
  CC      arch/i386/pci/mmconfig.o
  CC      arch/i386/pci/direct.o
  CC      arch/i386/pci/fixup.o
  CC      arch/i386/pci/acpi.o
  CC      arch/i386/pci/legacy.o
  CC      arch/i386/pci/irq.o
  CC      arch/i386/pci/common.o
  LD      arch/i386/pci/built-in.o
  GEN     .version
  CHK     include/linux/compile.h
  UPD     include/linux/compile.h
  CC      init/version.o
  LD      init/built-in.o
  LD      .tmp_vmlinux1
drivers/built-in.o: In function `wol_calc_crc':
drivers/built-in.o(.text+0x69e02): undefined reference to `crc_ccitt'
make: *** [.tmp_vmlinux1] Error 1

// George

-- 
George Georgalis, Architect and administrator, Linux services. IXOYE
http://galis.org/george/  cell:646-331-2027  mailto:george@galis.org
Key fingerprint = 5415 2738 61CF 6AE1 E9A7  9EF0 0186 503B 9831 1631
