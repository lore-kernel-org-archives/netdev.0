From: James Morris <jmorris@namei.org>
Subject: Re: [v3] skbuff: Do not scrub skb mark within the same name space
Date: Thu, 16 Apr 2015 17:02:15 +1000 (AEST)
Message-ID: <alpine.LRH.2.11.1504161700130.23392@namei.org>
References: <20150415100107.GA3655@gondor.apana.org.au> <552E3B7A.2040701@6wind.com> <20150415102229.GA3917@gondor.apana.org.au> <20150415135739.GA5534@gondor.apana.org.au> <552E86A6.9000101@6wind.com> <20150416010326.GA10864@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1665246916-1497334712-1429167736=:23392"
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	linux-security-module@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20150416010326.GA10864@gondor.apana.org.au>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1665246916-1497334712-1429167736=:23392
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 16 Apr 2015, Herbert Xu wrote:

> On Wed, Apr 15, 2015 at 05:41:26PM +0200, Nicolas Dichtel wrote:
> > Le 15/04/2015 15:57, Herbert Xu a écrit :
> > >On Wed, Apr 15, 2015 at 06:22:29PM +0800, Herbert Xu wrote:
> > [snip]
> > >Subject: skbuff: Do not scrub skb mark within the same name space
> > >
> > >The commit ea23192e8e577dfc51e0f4fc5ca113af334edff9 ("tunnels:
> > Maybe add a Fixes tag?
> > Fixes: ea23192e8e57 ("tunnels: harmonize cleanup done on skb on rx path")
> > 
> > >harmonize cleanup done on skb on rx path") broke anyone trying to
> > >use netfilter marking across IPv4 tunnels.  While most of the
> > >fields that are cleared by skb_scrub_packet don't matter, the
> > >netfilter mark must be preserved.
> > >
> > >This patch rearranges skb_scurb_packet to preserve the mark field.
> > nit: s/scurb/scrub
> > 
> > Else it's fine for me.
> 
> Sure.
> 
> PS I used the wrong email for James the first time around.  So
> let me repeat the question here.  Should secmark be preserved
> or cleared across tunnels within the same name space? In fact,
> do our security models even support name spaces?

They don't support namespaces, and maintaining the label is critical for 
SELinux, at least, which mediates security for the system as a whole.


-- 
James Morris
<jmorris@namei.org>

--1665246916-1497334712-1429167736=:23392--
