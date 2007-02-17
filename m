From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] e1000: fix shared interrupt warning message
Date: Sat, 17 Feb 2007 15:38:32 -0500
Message-ID: <45D767C8.3040508@garzik.org>
References: <20070216223913.26963.76602.stgit@gitlost.site> <20070216223926.26963.52634.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47903 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932817AbXBQUie (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 15:38:34 -0500
In-Reply-To: <20070216223926.26963.52634.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/e1000/e1000_main.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)

applied 1-3, though patch #1 had a noticable lack of description.  you 
should describe your change, not just the condition that prompted it. 
operation reordering is something that people shouldn't have to /try/ to 
understand.  Things should just be obvious, and if not, document why.


