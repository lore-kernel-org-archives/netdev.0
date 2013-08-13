From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: [PATCH net v5 0/5] bnx2x: fixes
Date: Tue, 13 Aug 2013 08:30:43 -0400
Message-ID: <20130813123043.GA30192@d2.synalogic.ca>
References: <1376349903-3461-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
To: Dmitry Kravkov <dmitry@broadcom.com>, ariele@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:60033 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389Ab3HMMa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 08:30:57 -0400
Received: by mail-qa0-f43.google.com with SMTP id cl20so265850qab.16
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 05:30:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1376349903-3461-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/08/13 02:24, Dmitry Kravkov wrote:
> Hello Dave
> 
> Please consider applying the series of bnx2x fixes to net:
> 	* statistics may cause FW assert
> 	* missing fairness configuration in DCB flow
> 	* memory leak in sriov related part
> 	* Illegal PTE access
> 	* Pagefault crash in shutdown flow with cnic
> v1->v2
> 	* fixed sparse error pointed by Joe Perches
> 	* added missing signed-off from Sergei Shtylyov
> v2->v3
> 	* added missing signed-off from Sergei Shtylyov
> 	* fixed formatting from Sergei Shtylyov
> v3->v4
> 	* patch 1/6: fixed declaration order
> 	* patch 2/6 replaced with: protect flows using set_bit constraints
> v4->v5
> 	* patch 2/6: replace proprietary locking with semaphore
> 	* droped 1/6: since adds redundant code from Benjamin Poirier

I'm confused. Wasn't "[PATCH net v4 1/6] bnx2x: properly initialize
statistic counters" supposed to fix a race condition? According to
earlier communication with Ariel:
	In this issue a race condition at driver startup causes a second
	statistics query to be sent before the first one completes,
	resulting in a firmware assert and a stuck chip. A patch was
	sent upstream fixing this:
	http://patchwork.ozlabs.org/patch/264810/
