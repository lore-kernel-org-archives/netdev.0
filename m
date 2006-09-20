From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 12/23] e1000: Maybe stop TX if not enough free descriptors
Date: Wed, 20 Sep 2006 08:30:13 -0700
Message-ID: <45115E85.3090202@intel.com>
References: <20060919172623.4605.56860.stgit@gitlost.site> <20060919172859.4605.60855.stgit@gitlost.site> <45104719.9080708@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44973 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S1751625AbWITPcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2006 11:32:51 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <45104719.9080708@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Actually, I rescind the ACK.
> 
> The code should be inside a spinlock, and therefore not need this 
> additional check.
> 
> If this check were truly needed, then SMP code all over the kernel would 
> be broken.

I will drop the patch for now. Once Jesse is back next week he gets to explain 
all it to me :)

Auke
