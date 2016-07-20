From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2] jsonw: Fix indentation of ending "}"
Date: Wed, 20 Jul 2016 12:19:24 -0700
Message-ID: <20160720121924.689f15f5@xeon-e3>
References: <1468828277-19308-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36581 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752347AbcGTTTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 15:19:38 -0400
Received: by mail-pa0-f42.google.com with SMTP id pp5so20928253pac.3
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 12:19:38 -0700 (PDT)
In-Reply-To: <1468828277-19308-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Jul 2016 09:51:17 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Fix indentation of the very last "}" which is currently indented,
> leaving the last 2 "}" like this:
> \t}
> \t}
> EOF
> 
> So fix it to be:
> \t}
> }
> EOF
> 
> Fixes fcc16c2287 ("provide common json output formatter")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

This no longer applies, put in change to json_writer for bridge formatting.
Is it still needed?
