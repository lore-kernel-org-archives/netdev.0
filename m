From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1] neighbour : fix ndm_type type error issue
Date: Sat, 26 Jul 2014 01:24:57 +0200
Message-ID: <1406330697.989.145785925.1CA960AF@webmail.messagingengine.com>
References: <1406306339-16151-1-git-send-email-mypopydev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Jun Zhao <mypopydev@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	stephen hemminger <stephen@networkplumber.org>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Francesco Fusco <ffusco@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	Jiri Pirko <jiri@resnulli.us>,
	David Stevens <dlstevens@us.ibm.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406306339-16151-1-git-send-email-mypopydev@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 25, 2014, at 18:38, Jun Zhao wrote:
> ndm_type means L3 address type, in neighbour proxy and vxlan, it's
> RTN_UNICAST.
> NDA_DST is for netlink TLV type, hence it's not right value in this
> context.

The value of NDA_DST == RTN_UNICAST, otherwise we couldn't do this
change as it would alter e.g. arpd behavior.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
