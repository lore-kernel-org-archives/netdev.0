From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] ibmvnic: Add netdev_dbg output for debugging
Date: Tue, 8 Aug 2017 09:27:14 -0700
Message-ID: <20170808092714.5f15a1bf@xeon-e3>
References: <20170807190258.13228.24698.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jallen@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35881 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752062AbdHHQ1R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 12:27:17 -0400
Received: by mail-pf0-f172.google.com with SMTP id c28so16518210pfe.3
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 09:27:17 -0700 (PDT)
In-Reply-To: <20170807190258.13228.24698.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 07 Aug 2017 15:02:58 -0400
Nathan Fontenot <nfont@linux.vnet.ibm.com> wrote:

> To ease debugging of the ibmvnic driver add a series of netdev_dbg()
> statements to track driver status, especially during initialization,
> removal, and resetting of the driver.
> 
> Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>

Maybe use netif_dbg() and the message type stuff.
