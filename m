From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] 3c59x: Don't assign when a comparison is intended
Date: Sat, 25 Dec 2010 21:45:26 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012252144030.10759@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1012252125410.10759@swampdragon.chaosbits.net> <AANLkTi=Y4wDG6+AY1=8NuFLGuCidgqaU1LginfB1YpZH@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1802066534-1293309926=:10759"
Cc: netdev@vger.kernel.org,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	linux-kernel@vger.kernel.org
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=Y4wDG6+AY1=8NuFLGuCidgqaU1LginfB1YpZH@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1802066534-1293309926=:10759
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 25 Dec 2010, richard -rw- weinberger wrote:

> On Sat, Dec 25, 2010 at 9:30 PM, Jesper Juhl <jj@chaosbits.net> wrote:
> > Hi,
> >
> > In drivers/net/3c59x.c::vortex_probe1() we have this code:
> >
> >        if (gendev) {
> >                if ((pdev = DEVICE_PCI(gendev))) {
> >                        print_name = pci_name(pdev);
> >                }
> >
> >                if ((edev = DEVICE_EISA(gendev))) {
> >                        print_name = dev_name(&edev->dev);
> >                }
> >        }
> >
> > I believe these assignments were intended to be comparisons.
> > If I'm correct, then here's a patch to fix that up.
> 
> I don't think so. Look at the extra brackets.
> 
> The code can also written as:
> 
> pdev = DEVICE_PCI(gendev);
> if(pdev)
>   print_name = pci_name(pdev);
> 

Arrgh, I completely missed that - damn.
You are correct I think and my patch is wrong.
Thanks for taking a look.


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

--8323328-1802066534-1293309926=:10759--
