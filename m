From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Ask some help for the performance of Intel 82599 on Linux 4.1.15
Date: Tue, 23 Feb 2016 22:39:28 +0800
Message-ID: <56CC6F20.4000202@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	<jesse.brandeburg@intel.com>, <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"Don Skidmore" <donald.c.skidmore@intel.com>,
	<matthew.vick@intel.com>, <john.ronciak@intel.com>,
	<mitch.a.williams@intel.com>, <intel-wired-lan@lists.osuosl.org>,
	<netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff:

I use the Intel 82599 to run benchmark on my machine, the kernel version is 4.1.15, and I found that
when I run a single iperf by one port, the speed looks fine, it could run to 9.45Gb/s, it looks good. 
the command is: iperf -c 15.1.1.1 -t 100 -i 1

But when I run double iperf by two port from one single 82599 card, it looks strange, the speed could
only up the 6Gb/s + 6Gb/s = 12Gb/s, the total speed is not twice as much than one port, I try to
modify some param for tcp windows, it looks no effect, can you give me more suggestion?

Thanks
Ding
