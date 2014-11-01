From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: ethernet: xilinx: xilinx_emaclite:
 Compatible with 'xlnx,xps-ethernetlite-2.00.b' for QEMU using
Date: Sat, 01 Nov 2014 17:03:34 -0400 (EDT)
Message-ID: <20141101.170334.1183930795197912809.davem@davemloft.net>
References: <54544E98.4060007@gmail.com>
	<54545AB9.70206@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michal.simek@xilinx.com, soren.brinkmann@xilinx.com,
	sthokal@xilinx.com, manuel.schoelling@gmx.de,
	paul.gortmaker@windriver.com, f.fainelli@gmail.com,
	ebiederm@xmission.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: gang.chen.5i5j@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54545AB9.70206@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chen Gang <gang.chen.5i5j@gmail.com>
Date: Sat, 01 Nov 2014 11:59:53 +0800

> On 11/1/14 11:08, Chen Gang wrote:
>> When use current latest upstream qemu (current version: 2.1.2), need let
>> driver compatible with 'xlnx,xps-ethernetlite-2.00.b', or can not find
>> net device in microblaze qemu. Related QEMU commands under fedora 20:
>> 
>>   yum install libvirt
>>   yum install tunctl
>>   tunctl -b
>>   ip link set tap0 up
>>   brctl addif virbr0 tap0
>>   ./microblaze-softmmu/qemu-system-microblaze -M petalogix-s3adsp1800 \
>>     -kernel ../linux-stable.microblaze/arch/microblaze/boot/linux.bin \
>>     -no-reboot -append "console=ttyUL0,115200 doreboot" -nographic \
>>     -net nic,vlan=0,model=xlnx.xps-ethernetlite,macaddr=00:16:35:AF:94:00 \
>>     -net tap,vlan=0,ifname=tap0,script=no,downscript=no
>> 
>>   in microblaze qemu bash (guest machine):
>> 
>>     ifconfig eth0 add 192.168.122.1 netmask 255.255.255.0
> 
> Oh, sorry, it is 192.168.122.2 (192.168.122.1 is the router address).
> 
> Thanks.
> 
>>     ifconfig eth0 up
>> 
>> After add this patch, can find the device, and can be used by 'telnetd'
>> (need cross-build busybox with glibc for it), then outside can telnet to
>> it without password.
>> 
>> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>

Applied with correct commit message, thanks.
