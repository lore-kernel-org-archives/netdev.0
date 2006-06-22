From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 11/21] e1000: disable CRC stripping workaround
Date: Wed, 21 Jun 2006 22:31:12 -0700
Message-ID: <449A2B20.2020006@candelatech.com>
References: <20060622051815.25497.89192.stgit@gitlost.site> <20060622052029.25497.67575.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:23752 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932256AbWFVFd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:33:29 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060622052029.25497.67575.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> CRC stripping is breaking SMBUS-connected BMC's. We disable this
> feature to make it work. This fixes related bugs regarding SOL.

Shouldn't you also have to subtract 4 bytes when setting the skb len
in the receive logic?  Perhaps when setting the rx-bytes counter as well?

Ben

