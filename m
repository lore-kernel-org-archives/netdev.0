From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH wireless-dev 2/5] orinoco: Switch to d80211.h
Date: Mon, 24 Jul 2006 00:06:49 -0400
Message-ID: <44C44759.6060504@garzik.org>
References: <200607232040.37823.flamingice@sourmilk.net> <20060724040355.GA6823@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Wu <flamingice@sourmilk.net>, linville@tuxdriver.com,
	Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	proski@gnu.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:19624 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751402AbWGXEHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 00:07:00 -0400
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060724040355.GA6823@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> On Sun, Jul 23, 2006 at 08:40:20PM -0700, Michael Wu wrote:
>> orinoco: Switch to d80211.h
>>
>> This patch "converts" the orinoco driver to use d80211.h instead of
>> ieee80211.h. It also copies the IEEE80211_DATA_LEN definition to
>> d80211.h for use by the stack and drivers.
> 
> NACK for all of these patches.  The names in ieee80211.h
> 
>  a) make a whole lot more sense
>  b) are used all over the kernel already
> 
> please convert the devicescape stack to reuse existing infrastrucure instead,
> and that starts with things as simple as names for constants and data
> structures in headers.

Agreed...

	Jeff



