From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [Updated patch] Re: [PATCH] igb: fix kexec with igb
Date: Tue, 31 Mar 2009 22:27:12 +0200
Message-ID: <200903312227.13788.rjw@sisk.pl>
References: <49B1F934.5050006@kernel.org> <EA929A9653AAE14F841771FB1DE5A1365F71995716@rrsmsx501.amr.corp.intel.com> <9929d2390903311251n43988214y6f1b2defa87e1a48@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	Yinghai Lu <yinghai@kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:44957 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754130AbZCaU1Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2009 16:27:25 -0400
In-Reply-To: <9929d2390903311251n43988214y6f1b2defa87e1a48@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 31 March 2009, Jeff Kirsher wrote:
> On Tue, Mar 31, 2009 at 12:14 PM, Tantilov, Emil S
> <emil.s.tantilov@intel.com> wrote:
> >
> > The patch checks out. I tested suspend/resume (including WOL) and kexec. There is only a small issue with warning on compile when CONFIG_PM is disabled:
> >
> > diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
> > index 13fe162..0a4f8f4 100644
> > --- a/drivers/net/igb/igb_main.c
> > +++ b/drivers/net/igb/igb_main.c
> > @@ -135,8 +135,8 @@ static inline int igb_set_vf_rlpml(struct igb_adapter *, int, int);
> >  static int igb_set_vf_mac(struct igb_adapter *adapter, int, unsigned char *);
> >  static void igb_restore_vf_multicasts(struct igb_adapter *adapter);
> >
> > -static int igb_suspend(struct pci_dev *, pm_message_t);
> >  #ifdef CONFIG_PM
> > +static int igb_suspend(struct pci_dev *, pm_message_t);
> >  static int igb_resume(struct pci_dev *);
> >  #endif
> >  static void igb_shutdown(struct pci_dev *);
> >
> > Thanks,
> > Emil
> >
> 
> Rafael - Based on Emil's testing, I will modify the patch with Emil's
> suggestion and push to Dave, ok?

Fine with me.

Thanks,
Rafael
