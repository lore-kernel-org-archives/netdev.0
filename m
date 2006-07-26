From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 10/24] RT2x00: Add software and hardware sequence counting
Date: Wed, 26 Jul 2006 19:48:35 +0200
Message-ID: <200607261948.35770.IvDoorn@gmail.com>
References: <200607261905.08494.IvDoorn@gmail.com> <20060726193337.27923ef1@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:5990 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751726AbWGZRss (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 13:48:48 -0400
Received: by nf-out-0910.google.com with SMTP id o25so827554nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 10:48:46 -0700 (PDT)
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060726193337.27923ef1@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > Add software sequence number counting to rt2400pci and rt2500pci,
>
> Ah, we don't support sequence numbering in d80211? Why didn't you yell
> at me?

To be the honest the same reason as why I didn't yell about RTS,
I had placed it on my todo list for d80211. ;)
But due to limited time I have never started on it, and I still had to look to 
see if it belongs in d80211 or in the driver. Very often the device itself is 
handling the sequence counting. rt2400pci and rt2500pci just seem to be the
exception.

Ivo
