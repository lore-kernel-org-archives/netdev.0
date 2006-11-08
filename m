From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/11] convert d80211 to a proper protocol
Date: Wed, 08 Nov 2006 08:36:04 -0500
Message-ID: <4551DD44.7000004@garzik.org>
References: <1162741174.24574.22.camel@johannes.berg>	<20061106210145.6824bec6@griffin.suse.cz>	<1162847394.1412.17.camel@johannes.berg> <20061108125844.46831cda@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Simon Barber <simon@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	David Kimdon <david.kimdon@devicescape.com>,
	James Ketrenos <jketreno@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52357 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965753AbWKHNgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 08:36:17 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061108125844.46831cda@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Benc wrote:
> On Mon, 06 Nov 2006 22:09:54 +0100, Johannes Berg wrote:
>>> What did happen with
>>> d80211: add a function to get the wiphy index
>>> d80211: add a perm_addr hardware property
>>> d80211: add a struct device* hardware property
>>> d80211: add a ethtool_ops hardware property
>>> patches?
>> Well after some chat with a few people I decided that it was stupid and
>> not very maintainable to copy all the fields in net_device to a new
>> structure.
> 
> Ok. Personally, I don't care if we pass net_device or ieee80211_local
> to drivers. I see pros and cons of both solutions.

Agreed.  Though if using ieee80211_local, please remove the "_local".  A 
better name is needed.

	Jeff



