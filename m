From: Joe Perches <joe@perches.com>
Subject: Re: [Patch] fix packet loss and massive ping spikes with PPP
 multi-link
Date: Fri, 26 Mar 2010 09:33:29 -0700
Message-ID: <1269621210.1541.102.camel@Joe-Laptop.home>
References: <2d460de71003260850x7f90d04cy79ac853464108182@mail.gmail.com>
	 <20100326160226.0159ac3b@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Hartmann <richih.mailinglist@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100326160226.0159ac3b@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-03-26 at 16:02 +0000, Alan Cox wrote:
> > We are fully aware that this code is not nearly up for inclusion into
> > the kernel. What we hope to achieve is that someone with the skills to
> > do this properly will introduce an option to turn off fragmentation on
> > PPP multi-link or to just do away with it completely.
> 
> You should be able to manage that I'm sure:
[]
> MODULE_PARM_DESC(ml_expode, "Set this to zero to disabling multilink \
> 	fragmentation when talking to cisco devices");

trivial:

It's better to use something like:

MODULE_PARM_DESC(ml_expode, "Set this to zero to disable multilink "
			    "fragmentation when talking to cisco devices");

so odd spacing from the continuation line aren't
used in the description.
