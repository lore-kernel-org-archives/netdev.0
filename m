From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [Patch]: IPv6 Connection Tracking
Date: Thu, 25 Sep 2003 21:57:47 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309252151180.11253-100000@netcore.fi>
References: <1064515680.995.41.camel@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>,
        Netfilter Devel <netfilter-devel@lists.netfilter.org>,
        Netdev <netdev@oss.sgi.com>, <usagi-core@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andras Kis-Szabo <kisza@securityaudit.hu>
In-Reply-To: <1064515680.995.41.camel@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

First, a meta-comment:

What I fear is that in the end, nothing gets done because having the goal
set to perfection.  If there is no energy to drive through the
L3-independent connecting tracking, the end result is that the user does
not have this feature (remember ip6tables REJECT target?  That must have
been sitting in netfilter for some 2+ years, and not having been
integrated in the mainline kernel and the users still do not have the
feature!).

So, my personal take is:
 - if a L3-independent conn tracking can be done *quickly*, fine,
 - if not, just merge the current one, start working on L3 independent 
conn tracking, and add it when available.

.. but I'm not the one who's answering the support emails, so in all 
fairness, I should be silent now..

Two questions/comments inline:

On 25 Sep 2003, Andras Kis-Szabo wrote:
[...]
> Your FTP code uses EPSV and EPRT from rfc2428. What's about the FOOBAR
> RFC (1639)? OK, it's a joke :)
> Could we open an IPv4 data connection next to the IPv6 controll
> connection?

What about LPRT and LPSV?

Btw, I would appreciate any comments regarding my draft documenting some 
IPv6-related Firewalling issues (some certainly come up when 
implementing): 
http://www.ietf.org/internet-drafts/draft-savola-v6ops-firewalling-01.txt

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
