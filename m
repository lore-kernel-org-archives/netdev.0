From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v1] net-sysfs: expose permanent hardware address in
 sysfs
Date: Wed, 07 May 2014 16:16:49 -0400 (EDT)
Message-ID: <20140507.161649.9479206877775994.davem@redhat.com>
References: <cover.1399347193.git.decot@googlers.com>
	<cd90d330753ff145d209240a72caafac32f5e750.1399347193.git.decot@googlers.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, edumazet@google.com,
	ebiederm@xmission.com, chenweilong@huawei.com, jiri@resnulli.us,
	mwdalton@google.com, viro@ZenIV.linux.org.uk, tj@kernel.org
To: decot@googlers.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cd90d330753ff145d209240a72caafac32f5e750.1399347193.git.decot@googlers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>
Date: Mon,  5 May 2014 20:34:00 -0700

> Tested:
>   grep . /sys/class/net/*/*addr*
> 
> Signed-off-by: David Decotigny <decot@googlers.com>

ETHTOOL_GPERMADDR exists already, please use that instead, thanks.
