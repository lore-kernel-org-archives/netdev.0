From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/6] isdn/hisax: add function declarations
Date: Mon, 26 Sep 2016 01:26:41 +0200
Message-ID: <201609260126.42034.arnd@arndb.de>
References: <1474694507-7379-1-git-send-email-baoyou.xie@linaro.org> <19682404.Wm2acsDIf0@wuerfel> <CA+DQWkxE_az1C1sZ9Tjqjsgm+-E5bbdNJ_REeH6qXvPdA8JuFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, linux-kernel.bfrz@manchmal.in-ulm.de,
        davem@davemloft.net, Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        xie.baoyou@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.135]:50433 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034674AbcIYXf2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 19:35:28 -0400
In-Reply-To: <CA+DQWkxE_az1C1sZ9Tjqjsgm+-E5bbdNJ_REeH6qXvPdA8JuFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 25 September 2016, Baoyou Xie wrote:
> > > @@ -1350,3 +1350,63 @@ static inline struct pci_dev
> > *hisax_find_pci_device(unsigned int vendor,
> > >  }
> > >
> > >  #endif
> > > +
> > > +#if CARD_TELES3
> > > +int setup_teles3(struct IsdnCard *card);
> > > +#endif
> > > +
> > > +#if CARD_TELESPCI
> > > +int setup_telespci(struct IsdnCard *card);
> > > +#endif
> > > +
> >
> > When you add the declarations here, just leave out the #if guards,
> > and put all the declarations here unconditionally, as we normally
> > do in the kernel.
> >
> > oh, in this case, we can leave the declarations out the  #if guards.
> but I suggest we don't do that still, cause of some declarations used by
> function parameters may reply on the macro.

They all have the same 'struct IsdnCard' argument, which is already
visible (otherwise none of them would work).

	Arnd
