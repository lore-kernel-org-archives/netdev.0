From: David Miller <davem@davemloft.net>
Subject: Re: tun: Failed to create tun sysfs files
Date: Fri, 04 Mar 2011 01:06:03 -0800 (PST)
Message-ID: <20110304.010603.104076956.davem@davemloft.net>
References: <201103030127.p231ReNl012841@imap1.linux-foundation.org>
	<4D70A929.4010900@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	mm-commits@vger.kernel.org, jirislaby@gmail.com,
	netdev@vger.kernel.org, maxk@qualcomm.com, vtun@office.satix.net
To: jslaby@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D70A929.4010900@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jslaby@suse.cz>
Date: Fri, 04 Mar 2011 09:56:09 +0100

> On 03/03/2011 01:52 AM, akpm@linux-foundation.org wrote:
>> The mm-of-the-moment snapshot 2011-03-02-16-52 has been uploaded to
> 
> Hi, I'm seeing this with tun (also with earlier versions):

The name of the attribute was changed to netdev_group in order to
fix this problem, in fact quite some time ago.

See the last entry of the net_class_attributes array in
net/core/net-sysfs.c, if it isn't called "netdev_group"
something is awry.
