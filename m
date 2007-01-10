From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 3/3] chelsio: more rx speedup
Date: Wed, 10 Jan 2007 09:34:45 +0100
Message-ID: <200701100934.46203.netdev@axxeo.de>
References: <20061215190716.956791000@osdl.org> <20070109102647.05d92861@freekitty> <45A44A87.7070202@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:36808 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964785AbXAJIfF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 03:35:05 -0500
To: Divy Le Ray <divy@chelsio.com>
In-Reply-To: <45A44A87.7070202@chelsio.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray schrieb:
> Stephen Hemminger wrote:
> > On Tue, 9 Jan 2007 09:42:03 +0100
> > Ingo Oeser <netdev@axxeo.de> wrote:
> >> Stephen Hemminger schrieb:
> >>> -	if (fl->credits < drop_thres) {
> >>> +use_orig_buf:
> >>> +	if (fl->credits < 2) {
> >>>       
> >> Why 2? What does this magic number mean?
> > No idea, it was there in the original. (as a parameter).
> The T2 HW behaves nicely when it is guaranteed to have 2 available 
> entries in the rx free list.

Can we have a #define for this?

That would help people understand this issue more.
And don't be shy about errata, all hardware and software out there has 
them like the humans that made them :-)

Regards

Ingo Oeser
