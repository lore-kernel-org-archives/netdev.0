From: Mark Einon <mark.einon@gmail.com>
Subject: Re: [PATCH 5/8] staging: et131x: Remove unnecessary i2c_wack variable
Date: Thu, 21 Aug 2014 15:59:23 +0100
Message-ID: <20140821145923.GA23151@msilap.einon.net>
References: <1408573078-9320-1-git-send-email-mark.einon@gmail.com>
 <1408573078-9320-6-git-send-email-mark.einon@gmail.com>
 <CAOMZO5Du34=jpr5B_fHGZ+D_jNR0VSDy2BiO6jj8QByh7V40RQ@mail.gmail.com>
 <20140821091819.GA2230@msilap.einon.net>
 <CAOMZO5DYppH8kURS-eGk9sTD-CfBYt4hWQehKE01Hj=1JXMAdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 linux-kernel <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <CAOMZO5DYppH8kURS-eGk9sTD-CfBYt4hWQehKE01Hj=1JXMAdg@mail.gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 21, 2014 at 09:06:40AM -0300, Fabio Estevam wrote:
> Hi Mark,
> 
> On Thu, Aug 21, 2014 at 6:18 AM, Mark Einon <mark.einon@gmail.com> wrote:
> 
> >
> > Hi Fabio, thanks for the review.
> >
> > It's a space alignment of parameters to go with the previous change, to
> > keep wrapping consistent in the file:
> >
> > -       while (i2c_wack) {
> > +       while (1) {
> >                 if (pci_write_config_byte(pdev, LBCIF_CONTROL_REGISTER,
> > -                       LBCIF_CONTROL_LBCIF_ENABLE))
> > +                                         LBCIF_CONTROL_LBCIF_ENABLE))
> >
> > So what are you saying - are you just commenting, document it, put it
> > in a seperate patch?
> 
> Yes, it would be better if this part was part of a separate patch.

Ok, I'll remove the indenting changes and sned them in a future patch.
I'll submit a revised v2 of this one.

Cheers,

Mark
