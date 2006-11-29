From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] d80211: Reset assoc and auth retry counters
Date: Wed, 29 Nov 2006 11:10:15 -0500
Message-ID: <20061129161009.GA7569@tuxdriver.com>
References: <200611282056.05641.IvDoorn@gmail.com> <20061129150928.63bf9f02@griffin.suse.cz> <a32f33a40611290627q5fb9f905ued49bbae6f5670b3@mail.gmail.com> <20061129153307.72ba559d@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ivo Van Doorn <ivdoorn@gmail.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:12560 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S967453AbWK2QK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 11:10:56 -0500
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20061129153307.72ba559d@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 29, 2006 at 03:33:07PM +0100, Jiri Benc wrote:
> On Wed, 29 Nov 2006 15:27:06 +0100, Ivo Van Doorn wrote:
> > Shouldn't this last one be:
> > ieee80211_set_disassoc(dev, ifsta, 0)
> > 
> > This one is called from the IOCTL request to dissassociate,
> > so the interface should still be authenticated (with a valid
> > auth retry counter).
> 
> Yes, of course. Thanks for being watchful :-)

I'll massage this and apply it on top of wireless-dev, since I already
applied Ivo's patch.

John
-- 
John W. Linville
linville@tuxdriver.com
