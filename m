From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: [PATCH] net: packet: option to only pass skb protocol
Date: Tue, 05 Jan 2010 15:28:22 -0600
Message-ID: <4B43AEF6.6050701@nortel.com>
References: <20100105185732.GA30346@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755547Ab0AEVck@vger.kernel.org>
In-Reply-To: <20100105185732.GA30346@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/05/2010 12:57 PM, Michael S. Tsirkin wrote:
> When sending packets with a packet socket it is often necessary to set
> protocol in msg_name: otherwise the protocol field in the skb will not
> be set correctly.

What about automatically detecting the protocol from the data being sent
to avoid the necessity of specifying it in the first place?

Chris
