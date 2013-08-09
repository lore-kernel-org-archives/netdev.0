From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 2/2] net: asix: Move declaration of ax88172a_info to
 shared header
Date: Fri, 9 Aug 2013 14:53:58 -0300
Message-ID: <CAOMZO5Br3kug3OBi=cS+H57mUAKxhh2XdTuLBLyXt7JL=HYYuw@mail.gmail.com>
References: <1376069482-16951-1-git-send-email-broonie@kernel.org>
	<1376069482-16951-2-git-send-email-broonie@kernel.org>
	<CAOMZO5AHVcmb8DiqM_H12e9cD3zAt0ZGz8yrLDyq5FwwO+cSMA@mail.gmail.com>
	<20130809104016.236fcd9d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mark Brown <broonie@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linaro-kernel@lists.linaro.org,
	Mark Brown <broonie@linaro.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f171.google.com ([209.85.128.171]:36393 "EHLO
	mail-ve0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758468Ab3HIRx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 13:53:59 -0400
In-Reply-To: <20130809104016.236fcd9d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 9, 2013 at 2:40 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:

>> > +extern const struct driver_info ax88172a_info;
>>
>> You could drop the 'extern' here.
>>
>> All other function prototypes in this header file do not use 'extern'.
>
> That is data, not function prototype, so yes extern is needed.

You are right, sorry for the noise.
