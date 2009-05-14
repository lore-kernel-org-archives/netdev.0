From: Piotr =?iso-8859-2?q?Zi=EAcik?= <kosmo@semihalf.com>
Subject: Re: [PATCH 02/12] fs_enet: Add MPC5121 FEC support.
Date: Thu, 14 May 2009 14:38:22 +0200
Message-ID: <200905141438.23348.kosmo@semihalf.com>
References: <1241640919-4650-1-git-send-email-wd@denx.de>
	<20090506220954.5D3AF83420E8@gemini.denx.de>
	<fa686aa40905061539t4fa463aehe56fdb64d053135d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Content-Transfer-Encoding: quoted-printable
Cc: Wolfgang Denk <wd@denx.de>, Detlev Zundel <dzu@denx.de>,
	John Rigby <jrigby@gmail.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Scott Wood <scottwood@freescale.com>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <fa686aa40905061539t4fa463aehe56fdb64d053135d@mail.gmail.com>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Thursday 07 May 2009 00:39:25 Grant Likely napisa=B3(a):
> >> 512x are enabled in the same kernel?
> >
> > Hm... both architectures look sufficiently different to me that I
> > don't see sense in trying such a thing. Do you think that needs to be
> > supported?
>
> Yes!  :-)  It's not hard to do and it keeps the driver cleaner
> (IMNSHO).  I don't think it is quite possible at the moment due to
> cache coherency issues, but with Becky's recently merged dma ops
> changes it should be fixable.

Could you elaborate on the cache coherency issues in MPC5121
FEC context? Especially how these issues are related to the driver
binary compatibility. =


MPC5121 support was added to drivers/net/fs_enet. MPC52xx uses
drivers/net/fec_mpc52xx.c. Do you think that creating one universal
driver from these two is now possible? You said that it should be easy,
however you also said that cache coherency issues makes this imposible.

-- =

Best Regards.
Piotr Ziecik
