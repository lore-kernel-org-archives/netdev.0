From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 3/3] d80211: fix workqueue breakage
Date: Wed, 13 Dec 2006 19:13:30 +0100
Message-ID: <20061213191330.450865b1@griffin.suse.cz>
References: <200612121255.58183.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:55638 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932391AbWLMSNJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 13:13:09 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200612121255.58183.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 12 Dec 2006 12:55:53 -0500, Michael Wu wrote:
> -			schedule_work(&local->scan_work);
> +			schedule_work(&local->scan_work.work);

Hm, what is the preferred way here:
schedule_work(some_delayed_work.work)
or
schedule_delayed_work(some_delayed_work, 0)?
	
The result is the same, I just would like to know what is preferred so
next time when workqueues are rewritten ;-) we have fewer troubles.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
