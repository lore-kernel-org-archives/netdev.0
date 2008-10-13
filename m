From: "Bryan Wu" <cooloney@kernel.org>
Subject: Re: [PATCH 1/1] netdev: DM9000: Added typecasting to supress some warnings on Blackfin
Date: Mon, 13 Oct 2008 18:27:13 +0800
Message-ID: <386072610810130327xf5ec9f1w33614e93beb69b13@mail.gmail.com>
References: <1223889009-31336-1-git-send-email-cooloney@kernel.org>
	 <20081013091725.GG31627@trinity.fluff.org>
	 <48F314B7.3020708@hvsistemas.es>
	 <386072610810130252s52c11423r69851740975ff517@mail.gmail.com>
	 <8bd0f97a0810130324o17a2b98s6bb05670b814345d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Javier Herrero" <jherrero@hvsistemas.es>, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Mike Frysinger" <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.189]:44798 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbYJMK1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 06:27:14 -0400
Received: by rn-out-0910.google.com with SMTP id k40so775774rnd.17
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2008 03:27:13 -0700 (PDT)
In-Reply-To: <8bd0f97a0810130324o17a2b98s6bb05670b814345d@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 13, 2008 at 6:24 PM, Mike Frysinger <vapier.adi@gmail.com> wrote:
> On Mon, Oct 13, 2008 at 05:52, Bryan Wu wrote:
>> On Mon, Oct 13, 2008 at 5:28 PM, Javier Herrero wrote:
>>> So it seems that we must correct that in other place?
>>
>> Yes, we need to check the I/O read_write functions.
>
> and drop the CONFIG_BLACKFIN hacks in the dm90000 driver ... we
> rewrite the write* functions to out* ... probably because we dont
> provide any write* functions in our headers
> -mike
>

No problem, I will take care of that.

-Bryan
