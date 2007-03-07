From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [RFC] ARP notify option
Date: Wed, 7 Mar 2007 08:42:39 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0703070838010.8567@netcore.fi>
References: <20070301164214.4a40bc59@freekitty> <45E7764A.7000100@goop.org>
	<20070301173030.754514ec@freekitty>
	<20070305.203536.92584097.davem@davemloft.net>
	<20070306105132.52c77491@freekitty> <45EDDA8F.5060106@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, jeff@garzik.org, ian.pratt@xensource.com,
   virtualization@lists.osdl.org, netdev@vger.kernel.org,
   linux-kernel@vger.kernel.org, chrisw@sous-sol.org, ak@muc.de,
   akpm@linux-foundation.org,
   Stephen Hemminger <shemminger@linux-foundation.org>,
   David Miller <davem@davemloft.net>
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <virtualization-bounces@lists.osdl.org>
In-Reply-To: <45EDDA8F.5060106@nortel.com>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.osdl.org>
List-Help: <mailto:virtualization-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.osdl.org?subject=subscribe>
Sender: virtualization-bounces@lists.osdl.org
Errors-To: virtualization-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

On Tue, 6 Mar 2007, Chris Friesen wrote:
> Stephen Hemminger wrote:
>>  +arp_notify - BOOLEAN
>>  +	Define mode for notification of address and device changes.
>>  +	0 - (default): do nothing
>>  +	1 - Generate gratuitous arp replies when device is brought up
>>  +	    or hardware address changes.
>
> Did you consider using gratuitous arp requests instead?  I remember readi=
ng =

> about some hardware that updated its arp cache on gratuitous requests but=
 not =

> gratuitous replies.

You might be interested in taking a look at:

http://tools.ietf.org/id/draft-cheshire-ipv4-acd

There has been some follow-up discussion on this in the thread =

starting at:

http://www1.ietf.org/mail-archive/web/int-area/current/msg00611.html

In particular, you may be interested in this comment about ARP =

request and ARP reply for gratuitous ARP:

http://www1.ietf.org/mail-archive/web/int-area/current/msg00669.html

-- =

Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
