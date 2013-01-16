From: Alan Ott <alan@signal11.us>
Subject: Re: [PATCH 2/2] 6lowpan: Handle uncompressed IPv6 packets over 6LoWPAN
Date: Wed, 16 Jan 2013 16:53:03 -0500
Message-ID: <50F7213F.50601@signal11.us>
References: <1358315037-10043-1-git-send-email-alan@signal11.us> <1358315037-10043-3-git-send-email-alan@signal11.us> <20130116.162214.444431638469568669.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tony.cheneau@amnesiak.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130116.162214.444431638469568669.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/16/2013 04:22 PM, David Miller wrote:
> From: Alan Ott <alan@signal11.us>
> Date: Wed, 16 Jan 2013 00:43:57 -0500
>
>> +		local_skb = skb_copy_expand(skb, NET_SKB_PAD - 1,
>> +						skb_tailroom(skb), GFP_ATOMIC);
> This is not indented properly.
>
> When a function call spans multiple lines, the second and subsequent
> lines should be indented to the column right after the openning
> parenthesis of the call itself, using a combination of TAB and
> SPC characters as needed.

Thanks David, I'll fix and re-submit.

Alan.
