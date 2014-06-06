From: Dmitry Popov <ixaphire@qrator.net>
Subject: Re: [PATCH] ipip, sit: fix ipv4_{update_pmtu,redirect} calls
Date: Fri, 6 Jun 2014 23:17:38 +0400
Message-ID: <20140606231738.80a0a6d316d34eab5cd9cbf1@qrator.net>
References: <20140606225117.684592168760890b595a166d@qrator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	trivial@kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140606225117.684592168760890b595a166d@qrator.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 6 Jun 2014 22:51:17 +0400
Dmitry Popov <ixaphire@qrator.net> wrote:

> ipv4_{update_pmtu,redirect) were called with tunnel's ifindex (t->dev is a 

Should be read as 
ipv4_{update_pmtu,redirect} ...

I will resubmit the patch, sorry. :(
