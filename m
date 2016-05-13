From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 00/11] devlink: add support for shared buffer
 configuration and control
Date: Fri, 13 May 2016 14:44:35 -0700
Message-ID: <20160513144435.5a29a051@xeon-e3>
References: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, sfeldma@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36048 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753056AbcEMVoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 17:44:24 -0400
Received: by mail-pf0-f169.google.com with SMTP id c189so47854505pfb.3
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 14:44:24 -0700 (PDT)
In-Reply-To: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Apr 2016 09:51:42 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Jiri Pirko (11):
>   devlink: fix "devlink port" help message
>   list: add list_for_each_entry_reverse macro
>   list: add list_add_tail helper
>   devlink: introduce pr_out_port_handle helper
>   devlink: introduce helper to print out nice names (ifnames)
>   devlink: split dl_argv_parse_put to parse and put parts
>   devlink: introduce dump filtering function
>   devlink: allow to parse both devlink and port handle in the same time
>   devlink: implement shared buffer support
>   devlink: implement shared buffer occupancy control
>   devlink: add manpage for shared buffer
> 
>  devlink/devlink.c          | 1310 +++++++++++++++++++++++++++++++++++++++++---
>  include/linux/devlink.h    |   63 +++
>  include/list.h             |   16 +
>  man/man8/devlink-dev.8     |    2 +
>  man/man8/devlink-monitor.8 |    1 +
>  man/man8/devlink-port.8    |    2 +
>  man/man8/devlink-sb.8      |  313 +++++++++++
>  man/man8/devlink.8         |    5 +
>  8 files changed, 1636 insertions(+), 76 deletions(-)
>  create mode 100644 man/man8/devlink-sb.8
> 

I had to revert all this. Because you are depending on headers in net-next.
Please resubmit against net-next tree of iproute.
