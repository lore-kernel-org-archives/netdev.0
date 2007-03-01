From: Michal Schmidt <xschmi00@stud.feec.vutbr.cz>
Subject: Re: [PATCH] e1000 stop raw interrupts disabled nag from RT
Date: Thu, 01 Mar 2007 18:11:53 +0100
Message-ID: <45E70959.4070209@stud.feec.vutbr.cz>
References: <45E64080.4070004@mvista.com> <45E645F4.2090403@intel.com> <45E65DCF.8050903@mvista.com> <45E70586.60201@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Mark Huth <mhuth@mvista.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Ingo Molnar <mingo@elte.hu>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58997 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965430AbXCAROD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 12:14:03 -0500
In-Reply-To: <45E70586.60201@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Kok, Auke wrote:
> Mark Huth wrote:
>> Well, I'm not an expert on the realtime patches - but most any patch set 
>> from Ingo seems to set this off - we've run through a bunch all the way 
>> since 2.6.10.
> 
> that's bizarre, and would imply that Ingo himself never spotted this in ages, 
> not to mention never tell us about it?

Ingo's -rt patches have contained this change to e1000 for some time.
The code is perfectly fine as is for non-RT kernels, so maybe that's why
noone felt like telling you about it.

Michal
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)
Comment: Using GnuPG with Red Hat - http://enigmail.mozdev.org

iD8DBQFF5wlZabKV90ewf0QRAse3AJ979xur0u8X1DokSzaAMvLQCWPkXACfU9ss
xC05DAbFNAaFMLnQrzBKit0=
=I5mt
-----END PGP SIGNATURE-----
