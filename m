From: "Yinghai Lu" <yinghai.lu@amd.com>
Subject: Re: [2.6 patch] the scheduled eepro100 removal
Date: Wed, 28 Mar 2007 22:08:23 -0700
Message-ID: <86802c440703282208m1f79c682q876e4d08d9216cd2@mail.gmail.com>
References: <20070325145810.GI16477@stusta.de> <460AE997.90509@tmr.com>
	 <460AEB85.1020101@intel.com> <460AEF65.8070908@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Bill Davidsen" <davidsen@tmr.com>, "Adrian Bunk" <bunk@stusta.de>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	saw@saw.sw.com.sg, "Jesse Brandeburg" <jesse.brandeburg@intel.com>
To: "Jeff Garzik" <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.233]:2046 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965953AbXC2FIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 01:08:24 -0400
Received: by nz-out-0506.google.com with SMTP id s1so63736nze
        for <netdev@vger.kernel.org>; Wed, 28 Mar 2007 22:08:23 -0700 (PDT)
In-Reply-To: <460AEF65.8070908@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/28/07, Jeff Garzik <jgarzik@pobox.com> wrote:
> Kok, Auke wrote:
> Sounds sane to me.  My overall opinion on eepro100 removal is that we're
> not there yet.  Rare problem cases remain where e100 fails but eepro100
> works, and it's older drivers so its low priority for everybody.
>
> Needs to happen, though...
>

It seems that several Tyan Opteron base system that were using IPMI
add on card.  the IPMI card share intel 100Mhz nic onboard. you need
to use eepro100 instead of e100 otherwise the e100 will shutdown OOB
(out of Band) connection for IPMI when shut down the OS.

YH
