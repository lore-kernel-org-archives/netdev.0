From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6.0-test5][NETROM] timer code cleanup
Date: Sun, 21 Sep 2003 18:07:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030921180740.0051dd30.davem@redhat.com>
References: <1064145739.4349.28.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Vinay K Nallamothu <vinay.nallamothu@gsecone.com>
In-Reply-To: <1064145739.4349.28.camel@lima.royalchallenge.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 21 Sep 2003 17:32:19 +0530
Vinay K Nallamothu <vinay.nallamothu@gsecone.com> wrote:

> 1. move timer initialization into nr_init_timers so that we can use mod_timer
> 2. remove skb queue purge in af_netrom as its already done by nr_clear_queues
> 3. Use del_timer_sync in nr_loopback_clear

Looks good, applied.
