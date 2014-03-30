From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v2] net-sysfs: expose number of carrier on/off
 changes
Date: Sat, 29 Mar 2014 18:36:28 -0700
Message-ID: <20140329183628.509f1239@nehalam.linuxnetplumber.net>
References: <cover.1396111568.git.decot@googlers.com>
	<2fd338e34d809af14353a03bc1edd0935f332faf.1396111568.git.decot@googlers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Eric Dumazet <edumazet@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Weilong Chen <chenweilong@huawei.com>,
	Jiri Pirko <jiri@resnulli.us>, Amir Vadai <amirv@mellanox.com>,
	Michael Dalton <mwdalton@google.com>,
	Al Viro <viro@ZenIV.linux.org.uk>, Tejun Heo <tj@kernel.org>
To: David Decotigny <decot@googlers.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2fd338e34d809af14353a03bc1edd0935f332faf.1396111568.git.decot@googlers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 29 Mar 2014 09:48:35 -0700
David Decotigny <decot@googlers.com> wrote:

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

Is there a related SNMP MIB variable? should there be?
