From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]dump interface IPv6 multicast/anycast addresses through
 netlink
Date: Thu, 18 Mar 2004 23:32:55 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040318233255.4cacc92c.davem@redhat.com>
References: <20040319.155536.20327066.yoshfuji@linux-ipv6.org>
	<OF3E88B8EA.382D75F6-ON87256E5C.00272BAC-88256E5C.0027A5ED@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI.Hideaki/mashirle@us.ibm.com, netdev@oss.sgi.com,
        netdev-bounce@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Shirley Ma <xma@us.ibm.com>
In-Reply-To: <OF3E88B8EA.382D75F6-ON87256E5C.00272BAC-88256E5C.0027A5ED@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Mar 2004 23:16:52 -0800
Shirley Ma <xma@us.ibm.com> wrote:

> I am going to modify the patch,
> removing RTM_NEWMULTICAST replaced by RTM_GETMULTICAST,
> removing RTM_NEWANYCAST replaced by RTM_GETANYCAST.

Please remember to number the RTM_* values correctly, the low
order bits tell if the operation does a read or write
operation.
