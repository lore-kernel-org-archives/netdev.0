From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPSecv6/Neighbor discovery crash
Date: Fri, 22 Aug 2003 10:50:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030822105016.72e710b8.davem@redhat.com>
References: <200308220149.h7M1nlAU017798@faith.austin.ibm.com>
	<20030821184640.2cb89b87.davem@redhat.com>
	<20030822145553.0ca08046.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: latten@austin.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kazunori Miyazawa <kazunori@miyazawa.org>
In-Reply-To: <20030822145553.0ca08046.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Aug 2003 14:55:53 +0900
Kazunori Miyazawa <kazunori@miyazawa.org> wrote:

> I guess it is due to xfrm cache.

I don't think so, fl.fl_icmp_type will be different for ICMP echo flow
lookup than for the ndisc ones.  Therefore flow cache will not return
the older ndisc stacked DST for the ICMP echo flow lookup.
