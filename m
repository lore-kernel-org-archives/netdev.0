From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [PATCH] RFKILL: fix input layer initialisation
Date: Mon, 23 Jun 2008 09:22:39 -0400
Message-ID: <20080623091714.ZZRA012@mailhub.coreip.homeip.net>
References: <20080619112841.GA12051@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, IvDoorn@gmail.com
To: Dmitry Baryshkov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.243]:39429 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753665AbYFWNWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 09:22:43 -0400
Received: by hs-out-0708.google.com with SMTP id 4so278093hsl.5
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 06:22:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080619112841.GA12051@doriath.ww600.siemens.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dmitry,

On Thu, Jun 19, 2008 at 03:28:41PM +0400, Dmitry Baryshkov wrote:
> Initialise correctly last fields, so tasks can be actually executed
> 
> Also move rfkill-input initialisation to subsys level so that it's
> available before generic drivers probing occurs.
> 

Rfkill-input is an implementation of default policy of handling
wifi-related key presses, it is not mandatory and should not be
required for a driver to operate, it may even not be present in the
kernel and therefore module_init is the appropriate time for its
initialization. We don't expect user to start pushing WIFI buttons
while system just starting to boot up, do we?

-- 
Dmitry
