From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 06/21] e1000: add smart power down code
Date: Tue, 27 Jun 2006 07:40:14 -0700
Message-ID: <44A1434E.5040402@intel.com>
References: <20060622051815.25497.89192.stgit@gitlost.site> <20060622052018.25497.43884.stgit@gitlost.site> <44A08D35.7090007@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:6923 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1030200AbWF0OlJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 10:41:09 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <44A08D35.7090007@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> Smart Power Down is a power saving feature in newer e1000 hardware. We
>> disable it because it causes time to link to be long, but make it a
>> user choice.
>>
>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> ---
>>
>>  drivers/net/e1000/e1000.h       |    1 +
>>  drivers/net/e1000/e1000_main.c  |   15 +++++++++++++++
>>  drivers/net/e1000/e1000_param.c |   25 +++++++++++++++++++++++++
>>  3 files changed, 41 insertions(+), 0 deletions(-)
> 
> Since it's not default, who will actually use this?  Particularly since 
> it is only a module option, and not supported through ethtool (frown).

laptop users that frequently re-connect their cables might enable this 
function since it saves battery life.

Auke
