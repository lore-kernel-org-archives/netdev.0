From: Dmitry Baryshkov <dbaryshkov@gmail.com>
Subject: Re: [PATCH] RFKILL: fix input layer initialisation
Date: Mon, 23 Jun 2008 18:40:24 +0400
Message-ID: <20080623144024.GD8606@doriath.ww600.siemens.net>
References: <20080619112841.GA12051@doriath.ww600.siemens.net> <20080623091714.ZZRA012@mailhub.coreip.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, IvDoorn@gmail.com
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.191]:57160 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755757AbYFWOkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 10:40:35 -0400
Received: by fk-out-0910.google.com with SMTP id 18so2351073fkq.5
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 07:40:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080623091714.ZZRA012@mailhub.coreip.homeip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 23, 2008 at 09:22:39AM -0400, Dmitry Torokhov wrote:
> Hi Dmitry,
> 
> On Thu, Jun 19, 2008 at 03:28:41PM +0400, Dmitry Baryshkov wrote:
> > Initialise correctly last fields, so tasks can be actually executed
> > 
> > Also move rfkill-input initialisation to subsys level so that it's
> > available before generic drivers probing occurs.
> > 
> 
> Rfkill-input is an implementation of default policy of handling
> wifi-related key presses, it is not mandatory and should not be
> required for a driver to operate, it may even not be present in the
> kernel and therefore module_init is the appropriate time for its
> initialization. We don't expect user to start pushing WIFI buttons
> while system just starting to boot up, do we?

I do toggle the KEY_BLUETOOTH from the kernel driver early.
The preliminary patch can be found at
http://permalink.gmane.org/gmane.linux.ports.arm.kernel/43136

The idea was to drive the bluetooth chip attached to the UART from the
uart pm hook.


-- 
With best wishes
Dmitry

