From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e100 resume failure
Date: Tue, 05 Jun 2007 08:21:22 -0700
Message-ID: <46657F72.3080403@intel.com>
References: <20070530203738.819a1623.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:35497 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932250AbXFEPV0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 11:21:26 -0400
In-Reply-To: <20070530203738.819a1623.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> I was doing some suspend-to-ram testing on the Vaio with the 2.6.22-rc3-mm1
> lineup.  After 10 or 15 cycles a resume failed:
> 
> [  357.119436] Suspending device full
> [  357.120450] Suspending device zero
> [  358.084978] Suspending device port
> [  358.085664] Suspending device null
> [  358.086432] Suspending device kmem
> [  358.087200] Suspending device mem
> [  358.087975] Suspending device 00:09
> [  358.088764] Suspending device 00:08
> [  358.089546] Suspending device 00:07
> [  358.090343] Suspending device 00:06
> [  358.091125] Suspending device 00:05
> [  358.091912] Suspending device 00:04
> [  358.092702] Suspending device 00:03
> [  358.093486] Suspending device 00:02
> [  358.094272] Suspending device 00:01
> [  358.095074] Suspending device 00:00
> [  358.095863] Suspending device pnp0
> [  358.096672] Suspending device 0000:06
> [  358.097482] Suspending device 0000:07
> [  358.098275] Suspending device 0000:06:0b.0
> [  358.101644] Suspending device 0000:06:08.0
> [18014750.543703] ATA: abnormal status 0x7F on port 0x000118af
> [18014750.555105] e100: eth0: e100_exec_cb_wait: ucode load failed
> 
> and the machine hung.

I've been wondering about this one for a while but apart from a freak of nature 
nothing comes up and I have not seen this before. I'll try to keep an eye open 
for it.

Auke
