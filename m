From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re:
Date: Mon, 29 Jul 2013 08:17:22 -0700
Message-ID: <20130729081722.40ff66ad@nehalam.linuxnetplumber.net>
References: <1375103935-24242-1-git-send-email-tmricht@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Richter <tmricht@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:42397 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108Ab3G2PR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 11:17:29 -0400
Received: by mail-pd0-f174.google.com with SMTP id 3so4542290pdj.33
        for <netdev@vger.kernel.org>; Mon, 29 Jul 2013 08:17:26 -0700 (PDT)
In-Reply-To: <1375103935-24242-1-git-send-email-tmricht@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Jul 2013 15:18:55 +0200
Thomas Richter <tmricht@linux.vnet.ibm.com> wrote:

> Add support for the bridge fdb replace command to replace an
> existing entry in the vxlan device driver forwarding data base.
> The entry is identified with its unicast mac address and its
> corresponding remote destination information is updated.
> 
> This is useful for virtual machine migration and replaces the
> bridge fdb del and bridge fdb add commands.
> 
> It follows the same interface as ip neigh replace commands.
> 
> Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
> ---
> bridge/fdb.c |    4 +++-
> 1 files changed, 3 insertions(+), 1 deletions(-)
> 

Please resubmit with proper subject so it gets picked up by
patchwork and can be merged into iproute
