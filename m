From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next 02/13] driver: net: remove unnecessary skb NULL
 check before calling dev_kfree_skb_irq
Date: Mon, 18 Nov 2013 20:37:11 +0100
Message-ID: <1384803431.17916.31.camel@jlt4.sipsolutions.net>
References: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
	 <1383400074-30555-3-git-send-email-govindarajulu90@gmail.com>
	 <20131104.151230.1978898006990867916.davem@davemloft.net>
	 <alpine.LNX.2.03.1311111537020.2363@cisco.com>
	 <alpine.LNX.2.03.1311190055150.10646@gmail.com>
	 (sfid-20131118_202645_273732_9DB2CF91)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	schwidefsky@de.ibm.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	IvDoorn@gmail.com, sbhatewara@vmware.com, samuel@sortiz.org,
	chas@cmf.nrl.navy.mil, roland@kernel.org, isdn@linux-pingi.de,
	jcliburn@gmail.com,
	"Christian Benvenuti (benve)" <benve@cisco.com>,
	"Sujith Sankar (ssujith)" <ssujith@cisco.com>,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shahed.shaikh@qlogic.com, joe@perches.com, apw@canonical.com
To: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.03.1311190055150.10646@gmail.com> (sfid-20131118_202645_273732_9DB2CF91)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please don't top-post. You're making a lot of obvious mistakes, to the
likely effect that soon enough people won't even read your email.

> Did you have a chance to look at this? Let me know how you want me to
> fix this.

By not "fixing" anything?

> >> Is is quite unlikely thats skb is NULL. So it comes down to one extra
> >> if-branching statement or one extra assignment. I would prefer extra
> >> assignment to branching statement. In my opinion extra assignment is
> >> very little price we pay.
> >> 
> >> //govind
> >
> > Another way to solve the double NULL check is to define a new function
> > something like this
> >
> > dev_kfree_skb_NULL(struct sk_buff **skb)
> > {
> >       if(*skb) {
> >               free_skb(*skb);
> >               *skb=NULL;
> >       }
> > }
> >
> > and use this if you want to free a skb and make it NULL.
> > Is this approach better?

That's just ugly imho. Why do you want to "clean up" something that
doesn't need changing?

Anyway, just saying.

johannes
