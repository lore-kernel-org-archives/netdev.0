From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Problem while using VLAN
Date: Thu, 12 Jun 2003 18:12:08 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3EE924E8.8080003@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am trying to configure a few thousand (< 5000) VLAN devices on 2.5.70, and use 
following commands (in a loop) :

	vconfig add eth0 $i$j
	ifconfig eth0.$i$j 10.0.$i.$j broadcast <> netmask <> up
	ifconfig eth0.$i$j add fec0:1:2:$i::$j/64

I get following problems :
	1. After some time, I lose the link local and site local addresses on my eth0 
and eth1 interfaces which were added through autoconfig.
	2. After some time, I lose link local and site addresses on all VLAN devices 
(after creating a few thousand devices).
	3. I find two devices for each created device, eg two eth0.232 or eth0.45 
devices. So if I create 100 devices, I get 200.

Is there any reason for this to happen, and am I doing something wrong ? 
Alternatively, any fixes for this ?

Thanks,

- KK


