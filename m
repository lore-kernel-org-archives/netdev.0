From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [TCP]: Rexmit hint must be cleared instead of setting
 it
Date: Wed, 28 Mar 2007 22:29:05 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0703282223540.29833@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0703281629360.27182@kivilampi-30.cs.helsinki.fi>
 <20070328.120709.35017257.davem@davemloft.net> <20070328.121405.49244759.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-692498704-1175110145=:29833"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34028 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933204AbXC1T3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 15:29:09 -0400
In-Reply-To: <20070328.121405.49244759.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-692498704-1175110145=:29833
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 28 Mar 2007, David Miller wrote:

> From: David Miller <davem@davemloft.net>
> Date: Wed, 28 Mar 2007 12:07:09 -0700 (PDT)
> 
> > From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> > Date: Wed, 28 Mar 2007 16:31:50 +0300 (EEST)
> > 
> > > Stupid error from my side. Even though now that I noticed this,
> > > I hoped it would have been an optimization but no, the counter
> > > hint is then incorrect. Thus clearing is necessary for now (I
> > > still suspect though that this path is never executed).
> > > 
> > > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> > 
> > Better safe than sorry :-)
> > 
> > We can start putting more aggressive assertions around if you'd
> > like to get some invariants like that validated.
> 
> In case it's not clear I did apply this patch.

I think more this on Friday, maybe WARN_ON could be placed there so that 
no harm is being done if it ever get there, probably a candidate for 
unlikely, if this is really needed. Anyway, applying the NULL this patch 
does no harm (it was supposed to be that way right from the
beginning)... :-)

...but lets keep in mind that the actual goal is, of course, to get rid of 
the hint altogether, rather than doing these clearing things... :-)

-- 
 i.
---696243703-692498704-1175110145=:29833--
