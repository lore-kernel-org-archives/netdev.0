From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] xfrm ip6ip6
Date: Sun, 1 Jun 2003 02:01:42 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0306010158450.7298-100000@excalibur.intercode.com.au>
References: <87fzmv5ejc.wl@karaba.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@redhat.com, <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>,
   <usagi@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitsuru KANDA / =?ISO-2022-JP?B?GyRCP0BFRBsoQiAbJEI9PBsoQg==?= <mk@linux-ipv6.org>
In-Reply-To: <87fzmv5ejc.wl@karaba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 1 Jun 2003, Mitsuru KANDA / [ISO-2022-JP] 神田 充 wrote:

> Anyway, I have one discussion point.
> When we use 'setkey -D', xfrm ipip tunnels are displayed as unspec SAs.
> Do we need to filter out these xfrm_states other than AH/ESP/IPcomp 
> in case of PF_KEY based queries?

Good question.  We need to either filter them out or make sure they are 
displayed as ipip.

Part of the answer will depend on whether we want to expose xfrm-based 
ipip tunnels for general use, or only use them internally for ipcomp.


- James
-- 
James Morris
<jmorris@intercode.com.au>
