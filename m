From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: skbuff truesize incorrect.
Date: Thu, 22 May 2014 12:59:38 -0700
Message-ID: <1400788778.5367.163.camel@edumazet-glaptop2.roam.corp.google.com>
References: <537E4AFD.20304@mentor.com> <537E4F29.9080103@gmail.com>
	 <537E526F.8060608@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevich@gmail.com>, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, kamal@canonical.com,
	Ben Hutchings <bhutchings@solarflare.com>, edumazet@google.com,
	mszeredi@suse.cz, fw@strlen.de
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <537E526F.8060608@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-05-22 at 20:39 +0100, Jim Baxter wrote:

> I now think that the correct solution here is to create a new smaller
> skb and copy the data from the sub packets into it.

For low speed devices, this is indeed the best way.

(this is called copybreak in some nic drivers)
