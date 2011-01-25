From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH] xen: netfront: Drop GSO SKBs which do not
 have csum_blank.
Date: Tue, 25 Jan 2011 17:09:36 +0000
Message-ID: <1295975376.14780.6595.camel@zakaz.uk.xensource.com>
References: <1294233811-28123-1-git-send-email-ian.campbell@citrix.com>
	<4D3A2BD2.5030802@goop.org>
	<1295689392.3693.153.camel@localhost.localdomain>
	<4D3DBD1C.6020503@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <4D3DBD1C.6020503@goop.org>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Mon, 2011-01-24 at 17:55 +0000, Jeremy Fitzhardinge wrote:
> No, I didn't mean to drop the skb_is_gso() test.  But still, the if()s
> can be folded to share the same body.

My original opinion was that sharing that bit of body at the expense of
an increasingly hard to decipher if conditional was not a good trade
off.

However thinking about it again I think the test logic would be better
of factored out into a validate_incoming_skb() type function anyway.
Short (2 patch) replacement series follows.

Ian.
