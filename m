From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: RFC: move SDP from AF_INET_SDP to IPPROTO_SDP
Date: Mon, 6 Mar 2006 11:48:53 -0800
Message-ID: <OFB3CB1E4D.355F7555-ON88257129.006C1001-88257129.006C836D@us.ibm.com>
References: <20060306190636.GA14849@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751037AbWCFTpZ@vger.kernel.org>
In-Reply-To: <20060306190636.GA14849@mellanox.co.il>
To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't know any details about SDP, but if there are no differences at the
protocol layer, then neither the address family nor the protocol is
appropriate. If it's just an API change, the socket type is the right
selector. So, maybe SOCK_DIRECT to go along with SOCK_STREAM,
SOCK_DGRAM, etc.
                                        +-DLS
