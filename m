From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2] net: don't call strlen on non-terminated string in
 dev_set_alias()
Date: Wed, 31 May 2017 08:37:06 -0700
Message-ID: <20170531083706.1baa729f@xeon-e3>
References: <20170531125150.28798-1-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Alexander Potapenko <glider@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170531125150.28798-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 May 2017 14:51:50 +0200
Alexander Potapenko <glider@google.com> wrote:

> +	/* alias comes from the userspace and may not be zero-terminated.
> +	 */
> +	memcpy(dev->ifalias, alias, len);

You don't need a multi-line comment here.
