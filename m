From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH net-next 1/3] net:dsa:mv88e6xxx: use hashtable to store
 multicast entries
Date: Fri, 16 Dec 2016 10:31:06 +0100
Message-ID: <ca8f4dd8-e039-a78a-88ae-818b5a9df303@phrozen.org>
References: <1481549958-1265-1-git-send-email-volodymyr.bendiuga@gmail.com>
 <87r35db35m.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <CAMr9Lbp5eCg1oyWGN+uiDEcF0VZuKUi87FH6JYTGj6pL82R+Mw@mail.gmail.com>
 <48ff1136-dd8f-7704-a512-c23b27989bf8@gmail.com>
 <20161212190915.GA8885@lunn.ch>
 <CAMr9LbqyvrRYe_m34Ufzxkf2Vef3LbMQiuoiwVX0mK=hW6euyA@mail.gmail.com>
 <20161213150948.GD20323@lunn.ch>
 <CABHmqqB-6-L124hrAjNxd4kO3zYp9R=RM1X6PXyuQW6Hapiv4g@mail.gmail.com>
 <20161214104614.GD27370@lunn.ch>
 <CABHmqqDpiN2kwkTgrM8Qu8EEx3Sjk2yVBy8QQAJppGfJ6-MV5Q@mail.gmail.com>
 <87eg19hzw1.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <be3b69b7-b6a3-a939-cf77-c62e5a1fe719@gmail.com>
 <87bmwdcc96.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <CABHmqqCOYMPA-Py7Uu4gsQ=s8CrQd-tT4-Db+j8eJH9=2s4L2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Volodymyr Bendiuga <valdr.linuxnext@gmail.com>,
        netdev@vger.kernel.org,
        Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
To: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:38024 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753495AbcLPKCu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Dec 2016 05:02:50 -0500
In-Reply-To: <CABHmqqCOYMPA-Py7Uu4gsQ=s8CrQd-tT4-Db+j8eJH9=2s4L2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 16/12/2016 10:24, Volodymyr Bendiuga wrote:
> Hi all,
> 
> Does this mean we all agree on implementing caching
> mechanism in net/dsa layer? If yes, then I can start
> working on it immediately.
> 
> Regards,
> Volodymyr

i think that the brcm approach is better as at least on QCA you can also
read auto learned values from the table which would get broken by a
caching mechanism. filtering inside the dump function or the code
calling the dump function seams a lot simpler and lightweight to me.

	John

> 
> On Thu, Dec 15, 2016 at 6:50 PM, Vivien Didelot
> <vivien.didelot@savoirfairelinux.com
> <mailto:vivien.didelot@savoirfairelinux.com>> wrote:
> 
>     Florian Fainelli <f.fainelli@gmail.com
>     <mailto:f.fainelli@gmail.com>> writes:
> 
>     >> In all cases *if caching is really needed*, I think it won't hurt to do
>     >> it in DSA core even if a switch support FDB dump operations on a
>     >> per-port basis, as Andrew mentioned.
>     >
>     > Agreed, and there does not appear to be any need to new dsa_switch_ops
>     > operations to be introduced?
> 
>     Nope.
> 
> 
