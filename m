From: "Alexey Klimov" <klimov.linux@gmail.com>
Subject: Re: [patch v2] net/usb: remove err() messages in few drivers
Date: Tue, 13 Jan 2009 13:08:27 +0300
Message-ID: <208cbae30901130208xe47d222g6928cf4243ea1dd8@mail.gmail.com>
References: <1231805322.12962.4.camel@tux.localhost>
	 <208cbae30901130057r2b3396f4gb5abdedd5647739c@mail.gmail.com>
	 <200901131025.40285.oliver@neukum.org>
	 <200901130144.26162.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Oliver Neukum" <oliver@neukum.org>, davem@davemloft.net,
	"Greg KH" <greg@kroah.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: "David Brownell" <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.190]:2178 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056AbZAMKI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 05:08:29 -0500
In-Reply-To: <200901130144.26162.david-b@pacbell.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 13, 2009 at 12:44 PM, David Brownell <david-b@pacbell.net> wrote:
> On Tuesday 13 January 2009, Oliver Neukum wrote:
>> > Ok, i'll reformat patch. Is it okay if i use kaweth->dev->dev,
>> > kaweth->net->dev and intf->dev ? Or switch to kaweth->net->dev
>> > (instead of dev->dev)?
>>
>> kaweth in kaweth_disconnect() frees the network device. Therefore
>> you cannot use it. You'd access freed memory. Pick one of the others
>> and stay with it.
>
> intf->dev is going to be "obviously correct", the others aren't.
>

Is this patch touch  kaweth_disconnect() ? I see dev_warn and dev_info
there. No dev_err.

-- 
Best regards, Klimov Alexey
