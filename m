From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next iproute2 0/3] ip: Initial support for extack
 errors
Date: Mon, 1 May 2017 20:34:27 -0700
Message-ID: <20170501203427.3c559ec6@cakuba.netronome.com>
References: <1493695105-9418-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:36577 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751145AbdEBDea (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 23:34:30 -0400
Received: by mail-pg0-f42.google.com with SMTP id t7so53783132pgt.3
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 20:34:30 -0700 (PDT)
In-Reply-To: <1493695105-9418-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  1 May 2017 20:18:22 -0700, David Ahern wrote:
> Introduce a new function, rtnl_ack_extack, to allow commands to flip
> to the new error reporting over time.
> 
> Convert iplink_modify to use the new function to display error strings
> returned from ip link set commands.

Tested-by: Jakub Kicinski <jakub.kicinski@netronome.com>
