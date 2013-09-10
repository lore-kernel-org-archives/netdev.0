From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: Re: [PATCH 1/1] net: bnx2x: Staticize local symbols
Date: Tue, 10 Sep 2013 15:05:27 +0530
Message-ID: <CAK9yfHxdbs=4saW0oLJgXmK9Be3FpP8rkZ7Y7v-yPbOtuCU+jA@mail.gmail.com>
References: <1378798960-6572-1-git-send-email-sachin.kamat@linaro.org>
	<6AE768456CEC4B4A9B2248CB6B87EB3E1BEE8FD8@SJEXCHMB05.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>
To: Ariel Elior <ariele@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:45656 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245Ab3IJJf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 05:35:27 -0400
Received: by mail-pd0-f175.google.com with SMTP id q10so7344417pdj.20
        for <netdev@vger.kernel.org>; Tue, 10 Sep 2013 02:35:27 -0700 (PDT)
In-Reply-To: <6AE768456CEC4B4A9B2248CB6B87EB3E1BEE8FD8@SJEXCHMB05.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10 September 2013 13:53, Ariel Elior <ariele@broadcom.com> wrote:
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of Sachin Kamat
>> Sent: Tuesday, September 10, 2013 9:43 AM
>> To: netdev@vger.kernel.org
>> Cc: davem@davemloft.net; Eilon Greenstein; sachin.kamat@linaro.org
>> Subject: [PATCH 1/1] net: bnx2x: Staticize local symbols

>>
>> -int bnx2x_vf_ndo_prep(struct bnx2x *bp, int vfidx, struct bnx2x_virtf **vf,
>> +static int
> I don't like this form. Better to put the last variable in the next line.

OK. Will change it.

>
> Thanks for suggesting the fix.
> Not sure this is appropriate for net though...

Sorry, did not get this. Please elaborate.

-- 
With warm regards,
Sachin
