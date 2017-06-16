From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 3/3] networking: make skb_push & __skb_push return void
 pointers
Date: Fri, 16 Jun 2017 11:24:48 +0200
Message-ID: <1497605088.2622.6.camel@sipsolutions.net>
References: <20170615221217.16510-1-johannes@sipsolutions.net>
         <20170615221217.16510-4-johannes@sipsolutions.net>
         <1497604758.10546.3.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: Joe Perches <joe@perches.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:58716 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753111AbdFPJYz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Jun 2017 05:24:55 -0400
In-Reply-To: <1497604758.10546.3.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-06-16 at 02:19 -0700, Joe Perches wrote:
> 
> >  			if (frag_size  ==
> > PN533_CMD_DATAFRAME_MAXLEN)
> > -				*skb_push(frag, sizeof(u8)) =
> > -							(PN533_CMD
> > _MI_MASK | 1);
> > -			else
> > -				*skb_push(frag, sizeof(u8)) =  1;
> > /* TG */
> > +				*(u8 *)skb_push(frag, sizeof(u8))
> > =
> > +									
> > (PN533_CMD_MI_MASK | 1);
> > +				else
> > +					*(u8 *)skb_push(frag,
> > sizeof(u8)) =  1; /* TG */
> 
> Can you check all the if/else uses.
> This one is not formatted correctly.
> I didn't look at any others.

Hmm, that's annoying. I did fix up a few, but I guess I missed this
one.

johannes
