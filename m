From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [RFC][PATCH v4 05/18] Add a function to indicate if device use
	external buffer.
Date: Sun, 25 Apr 2010 17:33:02 +0800
Message-ID: <t2g412e6f7f1004250233pbdfe4d8aj7dc0e0a4980d8eb9@mail.gmail.com>
References: <1272187206-18534-1-git-send-email-xiaohui.xin@intel.com>
	<1272187206-18534-2-git-send-email-xiaohui.xin@intel.com>
	<1272187206-18534-3-git-send-email-xiaohui.xin@intel.com>
	<1272187206-18534-4-git-send-email-xiaohui.xin@intel.com>
	<1272187206-18534-5-git-send-email-xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1272187206-18534-5-git-send-email-xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 25, 2010 at 5:19 PM,  <xiaohui.xin@intel.com> wrote:
> +static int dev_is_mpassthru(struct net_device *dev)
> +{
> + =C2=A0 =C2=A0 =C2=A0 if (dev && dev->mp_port)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 1;
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> +}
> +

Please make it a inline function. And you would write it with less
lines of code.

return dev && dev->mp_port;


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
