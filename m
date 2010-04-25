From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH v4 05/18] Add a function to indicate if device use
 external buffer.
Date: Sun, 25 Apr 2010 02:51:43 -0700 (PDT)
Message-ID: <20100425.025143.196865359.davem@davemloft.net>
References: <1272187206-18534-4-git-send-email-xiaohui.xin@intel.com>
	<1272187206-18534-5-git-send-email-xiaohui.xin@intel.com>
	<t2g412e6f7f1004250233pbdfe4d8aj7dc0e0a4980d8eb9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	jdike@linux.intel.com
To: xiaosuo@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <t2g412e6f7f1004250233pbdfe4d8aj7dc0e0a4980d8eb9@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Changli Gao <xiaosuo@gmail.com>
Date: Sun, 25 Apr 2010 17:33:02 +0800

> On Sun, Apr 25, 2010 at 5:19 PM,  <xiaohui.xin@intel.com> wrote:
>> +static int dev_is_mpassthru(struct net_device *dev)
>> +{
>> + =A0 =A0 =A0 if (dev && dev->mp_port)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> + =A0 =A0 =A0 return 0;
>> +}
>> +
>=20
> Please make it a inline function. And you would write it with less
> lines of code.
>=20
> return dev && dev->mp_port;

And use "bool" :-)
