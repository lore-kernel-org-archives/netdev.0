From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Allow controlling NAPI weight with sysfs
Date: Fri, 13 Mar 2015 14:15:09 -0700
Message-ID: <1426281309.11398.192.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAONBAadmkA6sXA7aJU5_LqFOs1iFzE1WoFW5xgoRfBT3rQKGiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, stephen@networkplumber.org
To: Ronald Pina <pinaronald@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:32898 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825AbbCMVPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 17:15:12 -0400
Received: by iecvj10 with SMTP id vj10so122873609iec.0
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 14:15:12 -0700 (PDT)
In-Reply-To: <CAONBAadmkA6sXA7aJU5_LqFOs1iFzE1WoFW5xgoRfBT3rQKGiw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-03-13 at 21:49 +0100, Ronald Pina wrote:
> Hello
> 
> I am working to allow controlling napi weight on kernel 3.18
> If may i ask, is it achievable since NAPI interface structure in
> current kernels is managed by the driver?
> 
> This feature was presented on kernel 2.6.12, here is a patch that can show
>  how was that implemented:
> 
> http://marc.info/?l=linux-netdev&m=111773621018096&w=2
> 
> As soon as on later kernel the weight was inserted on napi_struct, the
> weight wasn't exposed any more for every interface wth sysfs.
> 
> Please, any help or idea is very appreciated.

You did not explain why you would need to tweak weights from sysfs.
