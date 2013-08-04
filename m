From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute vxlan add support for fdb replace command
Date: Sun, 4 Aug 2013 11:57:51 -0700
Message-ID: <20130804115751.0bf8b584@nehalam.linuxnetplumber.net>
References: <1375165001-6776-1-git-send-email-tmricht@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Richter <tmricht@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:64953 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773Ab3HDS5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Aug 2013 14:57:54 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc17so2519192pbc.4
        for <netdev@vger.kernel.org>; Sun, 04 Aug 2013 11:57:54 -0700 (PDT)
In-Reply-To: <1375165001-6776-1-git-send-email-tmricht@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Jul 2013 08:16:41 +0200
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

Applied to master for next release.
