From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 4/5] cxgb3 - Stop mac RX when changing MTU
Date: Wed, 30 May 2007 20:47:29 -0700
Message-ID: <465E4551.8050504@chelsio.com>
References: <20070530170144.22843.74669.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:25606 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755601AbXEaDri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 23:47:38 -0400
In-Reply-To: <20070530170144.22843.74669.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

divy@chelsio.com wrote:
> From: Divy Le Ray <divy@chelsio.com>
>
> Rx traffic needs to be halted when the MTU is changed
> to avoid a potential chip hang.
> Reset/restore MAC filters around a MTU change.
> Also fix the pause frames high materwark setting.
>
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
>   

This patch has a flaw. The register used to stop broadcast/multicast 
traffic is wrong.
Please ignore this instance. I'm resending it.

Divy
