From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 1/4] xfrm_hash: kmalloc + memset conversion to kzalloc
Date: Mon, 26 Nov 2007 19:28:28 +0900
Message-ID: <b25c3fa70711260228u2524e26br8dab5105bd3ae6db@mail.gmail.com>
References: <007c01c8300b$176975a0$9c94fea9@jason>
	 <alpine.LFD.0.9999.0711260405110.362@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Robert P. J. Day" <rpjday@crashcourse.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.188]:23288 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754566AbXKZK22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 05:28:28 -0500
Received: by rv-out-0910.google.com with SMTP id k20so477320rvb
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2007 02:28:28 -0800 (PST)
In-Reply-To: <alpine.LFD.0.9999.0711260405110.362@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
> i believe the more common standard for the above is:
>
>  else if (hashdist) {
>
> to reduce the level of overall indentation, no?
>

No, it was.
Because there was a memset in that indentation, but I made it by
removing memset.

Thanks.
Joonwoo
