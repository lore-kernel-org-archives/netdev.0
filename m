From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Fri, 27 Sep 2002 19:28:43 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0209271918090.2895-100000@netcore.fi>
References: <200209271602.UAA21381@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.ORG>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200209271602.UAA21381@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 27 Sep 2002 kuznet@ms2.inr.ac.ru wrote:
> > This patch supports standard default source address selection
> > algorithm.
> 
> To all that I remember we had long discussion about this ages ago.
> I said I hate this. Such complicated selection without caching is _bug_.
> I see nothing improved since that time, except for the function became
> even more hairy. :-)

But you agree that a new selection is important, I think?

I agree that the spec as written (like, each address against every other, 
iterate N times etc.) seems to be like total crap.. but at least the 
intent seems to be clear-ish.

If caching was implemented I guess it would be triggered by:
 - address changes
 - route changes
 - a maximum lifetime of xx seconds?

Caching, if it can be done simply and reasonably seems like a very good
idea to me.

Btw I think labels are quite an important component of selection rules, as
it (similar to longest matching prefix) keeps certain classes of addresses
(e.g. 6to4, mapped addresses, compatible etc.) within the label.  That's
important.

User-manageable policy table is of less importance I think.

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
