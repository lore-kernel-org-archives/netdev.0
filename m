From: Michael Buesch <mb@bu3sch.de>
Subject: Re: softmac mtu
Date: Thu, 28 Sep 2006 17:35:17 +0200
Message-ID: <200609281735.17616.mb@bu3sch.de>
References: <ef3s4u$or5$3@sea.gmane.org> <1159365434.451a833ae7728@imp3-g19.free.fr> <1159365316.2698.40.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, castet.matthieu@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:25016
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S965052AbWI1Pgd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 11:36:33 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1159365316.2698.40.camel@ux156>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 27 September 2006 15:55, Johannes Berg wrote:
> On Wed, 2006-09-27 at 15:57 +0200, castet.matthieu@free.fr wrote:
> 
> > Also I wonder what should be the max mtu.
> 
> 2304, I think, as that's
> synonym sMaxMsduLng Integer = 2304; /* max octets in an MSDU */
> 
> But maybe I'm interpreting the spec wrongly?

Yes, I think so. ;)

I am pretty sure this is the maximum _fragment_ size.
But each packet (which max size is defined by the MTU) can
be fragmented. I don't know if there's a limit on the max
number of frags.

-- 
Greetings Michael.
