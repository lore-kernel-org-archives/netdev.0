From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: wireless netns work
Date: Thu, 18 Jun 2009 15:04:11 -0700
Message-ID: <43e72e890906181504i3b48b1fbj88fe485890e5f1a0@mail.gmail.com>
References: <1245328543.13790.31.camel@johannes.local> <1245329713.13790.37.camel@johannes.local>
	<40f31dec0906181016nffa031flac8f464c929f1bc9@mail.gmail.com>
	<43e72e890906181443g54269d1bm7ce24dcb46e7e921@mail.gmail.com>
	<1245361694.6495.2.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Nick Kossifidis <mickflemm@gmail.com>,
	Georgy Berdyshev <codingmaster@gmail.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f214.google.com ([209.85.217.214]:42138 "EHLO
	mail-gx0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757988AbZFRWE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 18:04:29 -0400
In-Reply-To: <1245361694.6495.2.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 18, 2009 at 2:48 PM, Johannes Berg<johannes@sipsolutions.net> wrote:
> On Thu, 2009-06-18 at 14:43 -0700, Luis R. Rodriguez wrote:
>
>> For example, I see you used mac80211_hwsim and was able to use two
>> wlan interfaces to talk to each other. This seems great for testing
>> purposes but it remains unclear to me the advantage of testing with
>> separate namespaces vs creating two wlan interfaces on one namespace
>> with mac80211_hwsim.
>
> You cannot ping within one namespace and have the packets actually flow
> over the virtual 'air'.

I see, thanks! How does using a separate namespace fix this limitation?

  Luis
