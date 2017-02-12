From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmvnic: Initialize completion variables before
 starting work
Date: Sat, 11 Feb 2017 21:24:36 -0500 (EST)
Message-ID: <20170211.212436.1146139307102503062.davem@davemloft.net>
References: <20170210184505.13381.72796.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jallen@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: nfont@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44480 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751088AbdBLCYi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2017 21:24:38 -0500
In-Reply-To: <20170210184505.13381.72796.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Fri, 10 Feb 2017 13:45:05 -0500

> Initialize condition variables prior to invoking any work that can
> mark them complete. This resolves a race in the ibmvnic driver where
> the driver faults trying to complete an uninitialized condition
> variable.
> 
> Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>

Applied.
