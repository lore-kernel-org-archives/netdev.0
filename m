From: Mihai Maruseac <mmaruseac@ixiacom.com>
Subject: Re: [PATCH] dev: use ifindex hash for dev_seq_ops
Date: Wed, 12 Oct 2011 12:59:23 +0300
Message-ID: <1318413563.2231.1.camel@sirius>
References: <1318000849-2531-1-git-send-email-mmaruseac@ixiacom.com>
	 <1318413446-22258-1-git-send-email-mmaruseac@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <dbaluta@ixiacom.com>, <mmaruseac@ixiacom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"mirq-linux@rere.qmqm.pl" <mirq-linux@rere.qmqm.pl>,
	"therbert@google.com" <therbert@google.com>,
	"jpirko@redhat.com" <jpirko@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Mihai Maruseac <mihai.maruseac@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318413446-22258-1-git-send-email-mmaruseac@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-10-12 at 02:57 -0700, Mihai Maruseac wrote:
> Instead of using the dev->next chain and trying to resync at each call to
> dev_seq_start, use the ifindex, keeping the last index in seq->private field.

Please consider only my last patch email, the first one was missing
Signed-off-by line.

Thanks,
Mihai
