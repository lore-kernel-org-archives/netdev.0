From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
	IRQF_SAMPLE_RANDOM
Date: Thu, 15 May 2008 20:46:18 -0300
Message-ID: <20080515234618.GA23721@khazad-dum.debian.net>
References: <482C8184.2030906@garzik.org> <482C8550.5000909@intel.com> <482C8D4D.3040702@garzik.org> <a24804730805151301s3c6644d0hc2c78b8008fe035d@mail.gmail.com> <20080515214721.GP18825@mit.edu> <482CB1FB.7080807@garzik.org> <20080515222941.GB20976@khazad-dum.debian.net> <482CBCC6.6010905@garzik.org> <20080515230221.GC20976@khazad-dum.debian.net> <20080515233642.GT18825@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Theodore Tso <tytso@mit.edu>, Jeff Garzik <jeff@garzik.org>,
	Chris Peterson <cpeterso@cpeterso.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Brandeb
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:34345 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755456AbYEOXqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 19:46:22 -0400
Content-Disposition: inline
In-Reply-To: <20080515233642.GT18825@mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 May 2008, Theodore Tso wrote:
> On Thu, May 15, 2008 at 08:02:21PM -0300, Henrique de Moraes Holschuh wrote:
> > I will tell you what.  If someone manages to get trousers to actually
> > *work* for data binding and sealing to the TPM in a ThinkPad T43 with an
> > NSC/Winbond TPM (their "sup3r s3kr1t TPM-inside-the-SuperIO 8394T" crap
> > one needs a NDA to get the documentation for), and I manage to duplicate
> > it (i.e. make it work here too), I will write the rng-tools trousers
> > interface code (at least for the Debian version) :-)
> > 
> > The kernel TPM driver works, the BIOS works, and I have the PCRs updated
> > properly during boot, but trousers get the tpm pubek key wrong for some
> > reason (the kernel driver can read it just fine).  The chip is good,
> > IBM's stuff worked just fine with it.
> 
> There were some web pages on this subject that seemed imply that IBM
> used a non-standard string-to-key algorithm, and that caused the

None of that, I cleared the TPM.  In fact, it took a while to find a
non-black-magic way to get the IBM BIOS to unhide the "Clear the TPM"
prompt...

Anyway, the TPM is clean, and I have tried with and without passphrases
(owner and operator), etc.  It is either a userspace to kernel
communications bug, or a trousers bug.  The PUBEK is there, the kernel
exports it nicely through sysfs, but trousers gets crap instead of the
PUBEK if I ask it to get the PUBEK (and therefore, nothing useful in
trousers works).

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh
