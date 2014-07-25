From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH 1/1] neighbour : fix ndm_type type error issue
Date: Fri, 25 Jul 2014 16:21:48 -0700
Message-ID: <CAHA+R7Nq1iZfLzUa+WY4=y33dna7PuN7cU0z5opRwZPsqeuznQ@mail.gmail.com>
References: <1406306339-16151-1-git-send-email-mypopydev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	stephen hemminger <stephen@networkplumber.org>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>,
	Francesco Fusco <ffusco@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jiri Pirko <jiri@resnulli.us>,
	David Stevens <dlstevens@us.ibm.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jun Zhao <mypopydev@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406306339-16151-1-git-send-email-mypopydev@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 25, 2014 at 9:38 AM, Jun Zhao <mypopydev@gmail.com> wrote:
> ndm_type means L3 address type, in neighbour proxy and vxlan, it's RTN_UNICAST.
> NDA_DST is for netlink TLV type, hence it's not right value in this context.
>

Looks correct to me, at least libnl uses RTN_* for ndm_type.
