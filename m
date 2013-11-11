From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [patch iproute2] ipaddress: add a black line for each device to
 make the output more readable
Date: Mon, 11 Nov 2013 17:31:00 +0100
Message-ID: <20131111173100.108e9026@griffin>
References: <1384182210-8901-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60867 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754679Ab3KKQbF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Nov 2013 11:31:05 -0500
In-Reply-To: <1384182210-8901-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Nov 2013 23:03:30 +0800, Hangbin Liu wrote:
> When we have multi links, the output huddled together and make it hard to read.
> Let's use the old ifconfig output style.

No. You can't break others' scripts like that.

bash$ function ip { /sbin/ip "$@" | sed '2,$s/^[0-9]*:/\n&/' ; }

^^^ Here, fixed that for you.

 Jiri

-- 
Jiri Benc
