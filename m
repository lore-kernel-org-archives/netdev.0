From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: in kernel 2.6.x, tun/tap nic supports vlan packets
Date: Thu, 24 Apr 2014 10:10:08 +0800
Message-ID: <53587280.4020101@gmail.com>
References: <534F4C1E.1000006@gmail.com> <20140417050228.GC8243@1wt.eu>	 <1398189237.7767.77.camel@deadeye.wl.decadent.org.uk>	 <53577036.2040307@gmail.com> <1398253309.7767.136.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, joe@perches.com, julia.lawall@lip6.fr,
	dingtianhong@huawei.com, linux-kernel@vger.kernel.org,
	jasowang@redhat.com, mst@redhat.com,
	"Yang, Zhangle (Eric)" <Zhangle.Yang@windriver.com>,
	"Wu, Kuaikuai" <Kuaikuai.Wu@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>, zhuyj <zyjzyj2000@gmail.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398253309.7767.136.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/23/2014 07:41 PM, Ben Hutchings wrote:
> On Wed, 2014-04-23 at 15:48 +0800, zhuyj wrote:
>> On 04/23/2014 01:53 AM, Ben Hutchings wrote:
> [...]
>>> For what it's worth, I would recommend against applying this.  I don't
>>> think even Red Hat has backported the VLAN changes, and they have been
>>> quite aggressive about backporting features to RHEL 6.
>> If we do not merge these patches, maybe RHEL 6 can not make tap driver
>> support vlan well.
> RHEL 6 isn't based on 2.6.32.y, they do all their own backporting.
Hi, Ben

It is well known that extraction vlan tag is not implemented in kernel 
2.6.32.y.  Kernel 2.6.32.y depends on nic hardware to extract vlan tag.
So if the patches are not applied, tap driver can not support vlan well.

Best Regards!
Zhu Yanjun
> Ben.
>
