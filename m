From: Simon Graham <simon.graham@citrix.com>
Subject: RE: [PATCH] xen/netback: calculate correctly the SKB slots.
Date: Tue, 22 May 2012 16:03:22 -0400
Message-ID: <F02ED76F3FCF8C468AD22A7618C05BBBB18DBFFEA4@FTLPMAILBOX01.citrite.net>
References: <1337621793-12486-1-git-send-email-konrad.wilk@oracle.com>
	 <1337627640.2979.33.camel@bwh-desktop.uk.solarflarecom.com>
	 <1337678512.10118.40.camel@zakaz.uk.xensource.com>
	 <20120522180901.GC22488@phenom.dumpdata.com>
	 <F02ED76F3FCF8C468AD22A7618C05BBBB18DBFFE61@FTLPMAILBOX01.citrite.net>
 <1337714930.3991.1.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Adnan Misherfi <adnan.misherfi@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337714930.3991.1.camel@dagon.hellion.org.uk>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> That sounds very plausible indeed!
> 
> Please can format this as a commit message and resend with a
> Signed-off-by.
> 

Will do
Simon

> many thanks,
> Ian.
> 
> >
> > We found this running with a VIF bridged to a USB 3G Modem where
> > skb->data started near the end of a page so the header would always
> > span the page boundary.
> >
> > It was very easy to get the VIF to stop processing frames with the old
> > code and we have not seen any problems since applying this patch.
> >
> > Simon
> >
> 
