From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: [2.6 patch] the scheduled eepro100 removal
Date: Wed, 3 Jan 2007 14:14:36 -0800
Message-ID: <4807377b0701031414o3eb8da81wededa7b7f6b26898@mail.gmail.com>
References: <20070102215726.GC20714@stusta.de>
	 <459AF3DC.1040305@tremplin-utc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Adrian Bunk" <bunk@stusta.de>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	saw@saw.sw.com.sg, "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:54867 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932140AbXACWOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 17:14:38 -0500
Received: by ug-out-1314.google.com with SMTP id 44so5291767uga
        for <netdev@vger.kernel.org>; Wed, 03 Jan 2007 14:14:36 -0800 (PST)
To: "Eric Piel" <Eric.Piel@tremplin-utc.net>
In-Reply-To: <459AF3DC.1040305@tremplin-utc.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/2/07, Eric Piel <Eric.Piel@tremplin-utc.net> wrote:
> Hi, I've been using e100 for years with no problem, however more by
> curiosity than necessity I'd like to know how will be handled the
> devices which are (supposedly) supported by eepro100 and not by e100?
>
> According to "modinfo eepro100" and "modinfo e100" those devices IDs are
> only matched by eepro100:
> +alias:          pci:v00008086d00001035sv
> +alias:          pci:v00008086d00001036sv
> +alias:          pci:v00008086d00001037sv
These are phoneline (RJ-11) adapters, I doubt it would work with e100
or eepro100

> +alias:          pci:v00008086d00001227sv
1227 doesn't exist as a pro/100 in our database, typo maybe?

> +alias:          pci:v00008086d00005200sv
doesn't exist in our database

> +alias:          pci:v00008086d00005201sv
This was the pro/100 intelligent server adapter with a pro/100 behind
a 960.  There aren't too many of these out there, and they usually
require some special configuration (although they can work as a dumb
nic, but why would you want a full length pro/100 card?)

> Are they matched by some joker rule that I haven't noticed in e100, or
> is support for them really going to disappear?

I think support for these devices can disappear (as I don't think they
will work anyway) but if someone complains we can take into account
what eepro100 did to support it (if anything) and enable it in e100.

Jesse (e100 maintainer)
