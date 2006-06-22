From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 11/21] e1000: disable CRC stripping workaround
Date: Thu, 22 Jun 2006 08:36:45 -0700
Message-ID: <449AB90D.2070605@intel.com>
References: <20060622051815.25497.89192.stgit@gitlost.site> <20060622052029.25497.67575.stgit@gitlost.site> <449A2B20.2020006@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:9655 "EHLO
	azsmga101-1.ch.intel.com") by vger.kernel.org with ESMTP
	id S1751153AbWFVPh1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 11:37:27 -0400
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <449A2B20.2020006@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Kok, Auke wrote:
>> CRC stripping is breaking SMBUS-connected BMC's. We disable this
>> feature to make it work. This fixes related bugs regarding SOL.
> 
> Shouldn't you also have to subtract 4 bytes when setting the skb len
> in the receive logic?  Perhaps when setting the rx-bytes counter as well?

the hardware corrects for the size properly when we disable CRC stripping. The 
end result is the same.

Cheers,

Auke
