From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] d80211: Reset assoc and auth retry counters
Date: Wed, 29 Nov 2006 15:33:07 +0100
Message-ID: <20061129153307.72ba559d@griffin.suse.cz>
References: <200611282056.05641.IvDoorn@gmail.com>
	<20061129150928.63bf9f02@griffin.suse.cz>
	<a32f33a40611290627q5fb9f905ued49bbae6f5670b3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:39892 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S967359AbWK2OdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 09:33:09 -0500
To: "Ivo Van Doorn" <ivdoorn@gmail.com>
In-Reply-To: <a32f33a40611290627q5fb9f905ued49bbae6f5670b3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Nov 2006 15:27:06 +0100, Ivo Van Doorn wrote:
> Shouldn't this last one be:
> ieee80211_set_disassoc(dev, ifsta, 0)
> 
> This one is called from the IOCTL request to dissassociate,
> so the interface should still be authenticated (with a valid
> auth retry counter).

Yes, of course. Thanks for being watchful :-)

 Jiri

-- 
Jiri Benc
SUSE Labs
