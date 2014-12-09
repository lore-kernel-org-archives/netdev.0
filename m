From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH net-next] tun: support retrieving multiple packets
 in a single read with IFF_MULTI_READ
Date: Tue, 9 Dec 2014 14:19:31 -0800
Message-ID: <20141209141931.68386652@urahara>
References: <1417752000-27171-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <jasonwang@redhat.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<mst@redhat.com>, <herbert@gondor.apena.org.au>,
	<kernel-team@fb.com>
To: Alex Gartrell <agartrell@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417752000-27171-1-git-send-email-agartrell@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 4 Dec 2014 20:00:00 -0800
Alex Gartrell <agartrell@fb.com> wrote:

>  
> +static inline size_t tun_calc_max_put_len(const struct tun_struct *tun)
> +{
> +	size_t len = 0;

No need for inline with local static function. Let compiler decide.
