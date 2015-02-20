From: Alex Pilon <alp@alexpilon.ca>
Subject: Re: [PATCH] Allow specifying bridge port STP state by name rather
 than number.
Date: Thu, 19 Feb 2015 23:57:30 -0500
Message-ID: <20150220045730.GA7936@alexpilon.ca>
References: <20150219192726.GA17950@alexpilon.ca>
 <CAPFHKzcOFQCtz0pwLm8XOZxTOkC9w4CFq2vcLnwxUfVVmWdNCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jonathon Reinhart <jonathon.reinhart@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alexpilon.ca ([69.165.220.233]:32906 "EHLO alexpilon.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751865AbbBTFHb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Feb 2015 00:07:31 -0500
Content-Disposition: inline
In-Reply-To: <CAPFHKzcOFQCtz0pwLm8XOZxTOkC9w4CFq2vcLnwxUfVVmWdNCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 19, 2015 at 09:00:23PM -0500, Jonathon Reinhart wrote:
> Please don't pass -1 to exit().  It is outside the acceptable range (0 to 255)
> of exit status values:
>
> https://www.gnu.org/software/libc/manual/html_node/Exit-Status.html
>
> Most programs exit(1) when presented with invalid user input.

I was being consistent with nearby code, and the dominant style.  But if
that's the case, then there's a few hundred such mistakes that need
correcting.  Should I fix all of them, and if so, should that be a
single patch, or multiple?

There's also only a few instances of EXIT_{SUCCESS,FAILURE}, so I took
it wasn't the style to use that.

Regards,

Alex Pilon
