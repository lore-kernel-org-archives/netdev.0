From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Sat, 07 Feb 2004 13:29:37 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040207.132937.126838355.yoshfuji@linux-ipv6.org>
References: <20040206195325.207aa1c7.davem@redhat.com>
	<OF293C5854.C480643B-ON88256E33.0016BE45-88256E33.0016EBE0@us.ibm.com>
	<20040206202438.13163677.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, hibi665@oki.com, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040206202438.13163677.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040206202438.13163677.davem@redhat.com> (at Fri, 6 Feb 2004 20:24:38 -0800), "David S. Miller" <davem@redhat.com> says:

> On Fri, 6 Feb 2004 21:12:59 -0700
> David Stevens <dlstevens@us.ibm.com> wrote:
> 
> > @@ -211,16 +219,11 @@
> > 
> >  int ip6_mc_input(struct sk_buff *skb)
> >  {
> > -     struct ipv6hdr *hdr;
> > -     int deliver = 0;
> > +     int deliver = 1;
> >       int discard = 1;
> 
> 'deliver' is always true now, please kill it and all the code
> trying to test it :)

We should test the destination address here.

--yoshfuji
