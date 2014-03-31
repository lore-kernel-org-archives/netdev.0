From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net-sysfs: expose number of carrier on/off
 changes
Date: Mon, 31 Mar 2014 16:25:19 -0400 (EDT)
Message-ID: <20140331.162519.2285405045402915587.davem@davemloft.net>
References: <cover.1396111568.git.decot@googlers.com>
	<2fd338e34d809af14353a03bc1edd0935f332faf.1396111568.git.decot@googlers.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org,
	edumazet@google.com, ebiederm@xmission.com, chenweilong@huawei.com,
	jiri@resnulli.us, amirv@mellanox.com, mwdalton@google.com,
	viro@ZenIV.linux.org.uk, tj@kernel.org
To: decot@googlers.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2fd338e34d809af14353a03bc1edd0935f332faf.1396111568.git.decot@googlers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>
Date: Sat, 29 Mar 2014 09:48:35 -0700

> This allows to monitor carrier on/off transitions and detect link
> flapping issues:
>  - new /sys/class/net/X/carrier_changes
>  - new rtnetlink IFLA_CARRIER_CHANGES (getlink)
> 
> Tested:
>   - grep . /sys/class/net/*/carrier_changes
>     + ip link set dev X down/up
>     + plug/unplug cable
>   - updated iproute2: prints IFLA_CARRIER_CHANGES
>   - iproute2 20121211-2 (debian): unchanged behavior
> 
> Signed-off-by: David Decotigny <decot@googlers.com>

Looks good, applied, thanks David.
