From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 06/21] e1000: add smart power down code
Date: Mon, 26 Jun 2006 21:43:17 -0400
Message-ID: <44A08D35.7090007@pobox.com>
References: <20060622051815.25497.89192.stgit@gitlost.site> <20060622052018.25497.43884.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:15828 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030599AbWF0BnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 21:43:19 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060622052018.25497.43884.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Smart Power Down is a power saving feature in newer e1000 hardware. We
> disable it because it causes time to link to be long, but make it a
> user choice.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000.h       |    1 +
>  drivers/net/e1000/e1000_main.c  |   15 +++++++++++++++
>  drivers/net/e1000/e1000_param.c |   25 +++++++++++++++++++++++++
>  3 files changed, 41 insertions(+), 0 deletions(-)

Since it's not default, who will actually use this?  Particularly since 
it is only a module option, and not supported through ethtool (frown).

	Jeff



