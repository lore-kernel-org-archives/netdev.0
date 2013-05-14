From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] igb: add a method to get the nic hw time stamping policy
Date: Tue, 14 May 2013 03:51:40 -0700
Message-ID: <5192173C.1070808@intel.com>
References: <20130511140219.GG8399@zhudong.nay.redhat.com> <518E7723.5010003@cogentembedded.com> <20130512142555.GI8399@zhudong.nay.redhat.com> <20130512172446.GA2484@netboy> <20130513021236.GJ8399@zhudong.nay.redhat.com> <20130513043140.GA2567@netboy> <20130513100742.GM8399@zhudong.nay.redhat.com> <20130514095155.GO8399@zhudong.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jacob Keller <Jacob.e.keller@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Tushar Dave <tushar.n.dave@intel.com>,
	Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	David Howells <dhowells@redhat.com>,
	Dave Jones <davej@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org, e10
To: Dong Zhu <bluezhudong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130514095155.GO8399@zhudong.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/14/2013 02:51 AM, Dong Zhu wrote:
> Hi,
>
>> I modified this patch and added the method to igb_get_ts_info functi=
on.
>> For 82576 nic, through this method we can easily check which type of=
 packets
>> are time stamped now, such as (HWTSTAMP_FILTER_PTP_V1_L4_SYNC and
>> HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ), then change or disable it up t=
o your requests.
>> I think it is convenient.The origial GET_TS_INFO method can only sho=
w the device=E2=80=99s
>> time stamping capabilities which nics supported.
> Through this method we can easily check which type of packets are
> timestamped currently, it is useful because that we use the hwstamp_c=
tl
> set time stamping policy first then we could verify what type of pack=
ets
> does the nic timestamp and then do some other testing(regression) for=
 each
> policy.No matter PTP is running or not we can make sure whether times=
tamp packets
> could cause other general network problems through viewing and settin=
g the
> timestamp policy.

I'm trying to follow this thread, and Richard's question keeps coming u=
p=20
in my head, and you've failed to answer it yet.

What are you trying to fix/solve?

It sounds like what you're trying to add can already be retrieved=20
through different mechanisms that already exist.

Please explain what you're trying to accomplish that doesn't already=20
exist today, and why it's important.  If the facility exists already,=20
then use that.  If it's not very usable, it can (maybe) be updated give=
n=20
what's deficient.  If it doesn't exist, then explaining why it needs to=
=20
exist will help the case for the patches.

Just providing code doesn't help answer the question of what you're=20
trying to do in the first place, and why what already exists isn't good=
=20
enough.

Regards,
-PJ
