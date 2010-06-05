From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v7 08/19] Make __alloc_skb() to get external buffer.
Date: Sat, 05 Jun 2010 16:53:24 +0200
Message-ID: <1275749604.5238.239.camel@edumazet-laptop>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-2-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-3-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-4-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-5-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-6-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-7-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-8-git-send-email-xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1275732899-5423-8-git-send-email-xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 05 juin 2010 =C3=A0 18:14 +0800, xiaohui.xin@intel.com a =C3=A9=
crit :
> From: Xin Xiaohui <xiaohui.xin@intel.com>
> 	child->fclone =3D SKB_FCLONE_UNAVAILABLE;
>  	}
> +	/* Record the external buffer info in this field. It's not so good,
> +	 * but we cannot find another place easily.
> +	 */
> +	shinfo->destructor_arg =3D ext_page;
> +


Yes this is a big problem, its basically using a cache line that was no=
t
touched before.
