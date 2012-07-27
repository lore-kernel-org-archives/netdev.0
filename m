From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 1/2] iproute: Add magic cookie to route dump file
Date: Fri, 27 Jul 2012 17:35:27 +0400
Message-ID: <5012991F.9030806@parallels.com>
References: <50121F4D.8090606@parallels.com> <AE90C24D6B3A694183C094C60CF0A2F6026B6FB1@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:14189 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751053Ab2G0Nfi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2012 09:35:38 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6FB1@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/27/2012 02:46 PM, David Laight wrote:
>> In order to somehow verify that a blob contains route dump a
>> 4-bytes magic is put at the head of the data and is checked
>> on restore.
> 
> Wouldn't a hash/checksum be useful as well?

I doubt it. This magic is not for data integrity check, but is
rather for identification of it. Is someone really needs a cheksum
of a dump, it can be added after file generation (and by the
preferred tool, not limited with the iproute implementation).

> Especially if it uneditable data.
> 
> 	David
> 
> 
> 
