From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v5 6/8] thunderbolt: Networking transmit and receive
Date: Fri, 29 Jul 2016 14:07:41 -0700
Message-ID: <20160729140741.18ca3e35@xeon-e3>
References: <1469693721-5641-1-git-send-email-amir.jer.levy@intel.com>
	<1469693721-5641-7-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: andreas.noever@gmail.com, gregkh@linuxfoundation.org,
	bhelgaas@google.com, corbet@lwn.net, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, thunderbolt-linux@intel.com,
	mika.westerberg@intel.com, tomas.winkler@intel.com
To: Amir Levy <amir.jer.levy@intel.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1469693721-5641-7-git-send-email-amir.jer.levy@intel.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 28 Jul 2016 11:15:19 +0300
Amir Levy <amir.jer.levy@intel.com> wrote:

> +		/* pad short packets */
> +		if (unlikely(skb->len < ETH_ZLEN)) {
> +			int pad_len = ETH_ZLEN - skb->len;
> +
> +			/* The skb is freed on error */
> +			if (unlikely(skb_pad(skb, pad_len))) {
> +				cleaned_count += frame_count;
> +				continue;
> +			}
> +			__skb_put(skb, pad_len);
> +		}

Packets should be padded on transmit, not on receive??
