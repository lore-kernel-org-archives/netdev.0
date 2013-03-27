From: Keun-O Park <kpark3469@gmail.com>
Subject: Re: [PATCH] ptp_pch: eliminate a number of sparse warnings
Date: Wed, 27 Mar 2013 13:59:06 +0900
Message-ID: <CA+KhAHa+Lu26EX2JsZsf3pMb65w7khbAnz=reXGrvV1z71Up0g@mail.gmail.com>
References: <1364359512-29228-1-git-send-email-kpark3469@gmail.com>
	<20130327.005138.1102221495315013055.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: richardcochran@gmail.com, keun-o.park@windriver.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:59124 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951Ab3C0E7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 00:59:07 -0400
Received: by mail-ia0-f174.google.com with SMTP id b35so7105947iac.33
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 21:59:06 -0700 (PDT)
In-Reply-To: <20130327.005138.1102221495315013055.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 27, 2013 at 1:51 PM, David Miller <davem@davemloft.net> wrote:
> From: kpark3469@gmail.com
> Date: Wed, 27 Mar 2013 13:45:12 +0900
>
>> -module_param_string(station, pch_param.station, sizeof pch_param.station, 0444);
>> +module_param_string(station,
>> +      pch_param.station, sizeof(pch_param.station), 0444);
>
> Function arguments on the second and subsequent line of a function
> call should line up with the first column after the colum of the
> openning parenthesis of the first line.
>
> Don't just use TAB characters exclusively, the above looks
> incredibly ugly.  Instead use the necessary combination of
> TAB and space characters necessary to make the argument
> line up at the correct column so it all lines up and looks
> nice.

Ah.. okay. I see.
Thanks.

-- kpark
