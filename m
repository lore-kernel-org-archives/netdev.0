From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: [PATCH 1/1] netdev: DM9000: Added typecasting to supress some warnings on Blackfin
Date: Mon, 13 Oct 2008 06:24:33 -0400
Message-ID: <8bd0f97a0810130324o17a2b98s6bb05670b814345d@mail.gmail.com>
References: <1223889009-31336-1-git-send-email-cooloney@kernel.org>
	 <20081013091725.GG31627@trinity.fluff.org>
	 <48F314B7.3020708@hvsistemas.es>
	 <386072610810130252s52c11423r69851740975ff517@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Javier Herrero" <jherrero@hvsistemas.es>, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Bryan Wu" <cooloney@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:13507 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbYJMKYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 06:24:34 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1761168rvb.1
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2008 03:24:33 -0700 (PDT)
In-Reply-To: <386072610810130252s52c11423r69851740975ff517@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 13, 2008 at 05:52, Bryan Wu wrote:
> On Mon, Oct 13, 2008 at 5:28 PM, Javier Herrero wrote:
>> So it seems that we must correct that in other place?
>
> Yes, we need to check the I/O read_write functions.

and drop the CONFIG_BLACKFIN hacks in the dm90000 driver ... we
rewrite the write* functions to out* ... probably because we dont
provide any write* functions in our headers
-mike
