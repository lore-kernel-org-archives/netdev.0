From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 2/5] switchdev: use new swdev ops
Date: Mon, 16 Mar 2015 08:44:54 +0900
Message-ID: <20150315234453.GB16756@penelope.isobedori.kobe.vergenet.net>
References: <1426400107-6072-1-git-send-email-sfeldma@gmail.com>
 <1426400107-6072-3-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@resnulli.us, roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34567 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515AbbCOXpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 19:45:44 -0400
Received: by pacwe9 with SMTP id we9so46728686pac.1
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 16:45:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1426400107-6072-3-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Scott,

On Sat, Mar 14, 2015 at 11:15:04PM -0700, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> 
> Move swdev wrappers over to new swdev ops (from previous ndo ops).  No
> functional changes to the implementation.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

I am a little concerned that this patch will break rocker and dsa until
the 3rd and 4th patches of this series are applied.

Also it is not entirely obvious to me why you check for !ops in
netdev_switch_parent_id_get() and netdev_switch_port_stp_update()
but not in netdev_switch_fib_ipv4_add() and netdev_switch_fib_ipv4_del().

[snip]
