From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] net sched: text ematch: zero out ts_state before using it
Date: Thu, 9 Oct 2014 14:48:54 -0700
Message-ID: <CAHA+R7Ot5u6F1zi4egLqOXPWbQrdLxdUQybaFEp5_aa463d4Bw@mail.gmail.com>
References: <1412870721-31061-1-git-send-email-osandov@osandov.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Omar Sandoval <osandov@osandov.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412870721-31061-1-git-send-email-osandov@osandov.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 9, 2014 at 9:05 AM, Omar Sandoval <osandov@osandov.com> wrote:
> textsearch_find zeroes out the offset, but the control buffer (which may or may
> not matter in this case) needs to be zeroed out as well.

Why? skb_prepare_seq_read() initializes the cb.

Also, the comment says:

 * @state: uninitialized textsearch state variable
