From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]dump interface IPv6 multicast/anycast addresses through
 netlink
Date: Thu, 18 Mar 2004 22:06:47 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040318220647.3dbb9c43.davem@redhat.com>
References: <200403171130.30282.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Shirley Ma <mashirle@us.ibm.com>
In-Reply-To: <200403171130.30282.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 17 Mar 2004 11:30:30 -0800
Shirley Ma <mashirle@us.ibm.com> wrote:

> This patch is against Linux 2.6.4 kernel. It has been tested, 'ip' utility 
> works fine. This patch is used by IPv6 MIBs.

Are we really going to support adding anycast/multicast addresses using
RTM_NEW{MULTI,ANY}CAST rtmsgs?  If not, let's not add them.

Otherwise I like your patch.
