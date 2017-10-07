From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: Fw: [Bug 197099] New: Kernel panic in interrupt [l2tp_ppp]
Date: Sat, 07 Oct 2017 19:38:48 +0300
Message-ID: <f74effad2ec9b6a1a1bdbf25d6bd3801@nuclearcat.com>
References: <20171001102110.24184f1b@xeon-e3>
 <CAEwTi7QkF73cc1hShzOoM9bzb5mBzyFW8t68OCn+XECrJ9d61Q@mail.gmail.com>
 <1506952566.8061.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <CA++DawY6CPh5S8A7pPE+-nwwGxJ4=pKL_MkXT_Q5TZb8xFnCjA@mail.gmail.com>
 <CAEwTi7S3-B81bNxyWq8j4hUpXyqNnTADReYoKoGF-V4wC5OBkQ@mail.gmail.com>
 <CAEwTi7SS7qsbV19NsPGwdiwTcejxygUEqQi-_MJ07uMec0CY9A@mail.gmail.com>
 <CA++DawbbfQq1ZGB_x5t4a9mhkkptnDfcDxtCXgHYfGpY=8q83g@mail.gmail.com>
 <CAEwTi7RF6s1OhEEPTrDzk61QQD_AFoZ+uX-WRhc=aAVHoHJxpw@mail.gmail.com>
 <CA++DawbMB8aFa3s-0jW2CC5pRTU2Ui4ec6GSRCkhMotGGj_Ytg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org,
        Guillaume Nault <g.nault@alphalink.fr>,
        netdev-owner@vger.kernel.org
To: SviMik <svimik@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:55252 "EHLO nuclearcat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751279AbdJGQiw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 7 Oct 2017 12:38:52 -0400
In-Reply-To: <CA++DawbMB8aFa3s-0jW2CC5pRTU2Ui4ec6GSRCkhMotGGj_Ytg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-10-07 15:09, SviMik wrote:
> 
> Unfortunately, netconsole has managed to send a kernel panic trace
> only once, and it's not related to this bug. Looks like something
> crashes really hard to make netconsole unusable.
In some cases i had luck with pstore, when netconsole failed me 
(especially networking bugs), it stores panic messages more reliably, 
especially on recent platforms who have ERST and EFI.
https://www.kernel.org/doc/Documentation/ABI/testing/pstore
