From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 0/11] convert d80211 to a proper protocol
Date: Sun, 5 Nov 2006 17:54:33 +0100
Message-ID: <200611051754.34099.IvDoorn@gmail.com>
References: <1162741174.24574.22.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>, Jouni Malinen <jkm@devicescape.com>,
	Simon Barber <simon@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	David Kimdon <david.kimdon@devicescape.com>,
	James Ketrenos <jketreno@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:18986 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1161319AbWKEQyo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Nov 2006 11:54:44 -0500
Received: by nf-out-0910.google.com with SMTP id c2so428053nfe
        for <netdev@vger.kernel.org>; Sun, 05 Nov 2006 08:54:43 -0800 (PST)
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1162741174.24574.22.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> I figured I'd look how hard it actually was to convert d80211 to a
> proper protocol. And contrary to my own expectations I succeeded in
> doing that in just over a day. Just like 8021q, it has virtual devices.
> 
> The patchset is huge and can be found at
> http://johannes.sipsolutions.net/files/d80211-proto/

I have a question regarding the enabling and disabling the radio
in this new layout.
Previously the open() and stop() methods in ieee80211_hw had been
deprecated and the driver should enable or disable the radio
based on the add_interface and remove_interface() functions.

Now that the driver should provide open() and stop() for the netdevice
structure does this mean that these 2 methods are back in control
for enabling and disabling the radio? And if so what should the
add_interface and remove_interface, should they be only in charge of
triggering some configuration changes (like mode and mac address)?

Ivo
