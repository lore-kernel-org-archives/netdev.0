From: Matt Mackall <mpm@selenic.com>
Subject: Re: Using netconsole and getting double prints
Date: Thu, 05 Nov 2009 23:17:43 -0600
Message-ID: <1257484663.2873.622.camel@calx>
References: <43e72e890911051654i19c18bf3nd397662ed79712c4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([173.11.57.241]:37436 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751853AbZKFFRq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Nov 2009 00:17:46 -0500
In-Reply-To: <43e72e890911051654i19c18bf3nd397662ed79712c4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-11-05 at 16:54 -0800, Luis R. Rodriguez wrote:
> I'm getting double prints when using netconsole. This used to happen
> to me and then I just enable debugging log level manually (dmesg -n 8)
> but now no matter what I try I always get double prints.

This is the first report I've seen of that. Recommend investigating with
wireshark.

> I capture my data with netcat script (I call it netlog):
> 
> #!/bin/bash
> echo "You should now run in another window: tail -f $HOME/log"
> while true; do
> 	/bin/nc -u -l -p 6666 >> $HOME/log
> done
> 
> This also just doesn't work if I run the nc manually without a redirect:
> 
> while true; do /bin/nc -u -l -p 6666; done

That really shouldn't make any difference.

-- 
http://selenic.com : development and support for Mercurial and Linux


