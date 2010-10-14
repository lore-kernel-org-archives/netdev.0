From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [PATCH net-next] tipc: cleanup function namespace
Date: Thu, 14 Oct 2010 09:31:08 -0400
Message-ID: <0434463FDA60A94FA978ACA44617682DEE845A5D2A@EUSAACMS0702.eamcs.ericsson.se>
References: <1286929558-2954-5-git-send-email-paul.gortmaker@windriver.com>
	<20101013162652.GF31379@hmsreliant.think-freely.org>
	<4CB5E79B.4060507@windriver.com>
	<20101013.142834.226768662.davem@davemloft.net>
 <20101013162035.0c2e8123@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"allan.stephens@windriver.com" <allan.stephens@windriver.com>
To: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr4.ericy.com ([198.24.6.8]:49387 "EHLO imr4.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754665Ab0JNNbc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 09:31:32 -0400
In-Reply-To: <20101013162035.0c2e8123@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Do some cleanups of TIPC based on make namespacecheck
>   1. Don't export unused symbols
>   2. Eliminate dead code
>   3. Make functions and variables local
>   4. Rename buf_acquire to tipc_buf_acquire since it is used 
> in several files
> 
> Compile tested only.
> This make break out of tree kernel modules that depend on 
> TIPC routines.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>