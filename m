From: Jesse Gross <jesse@nicira.com>
Subject: Re: bnx2 vlan issue
Date: Thu, 24 Mar 2011 12:55:08 -0700
Message-ID: <AANLkTi=zfhwHTB7kitgwk3AzSa0aFFyxgM_ZY-3wObR5@mail.gmail.com>
References: <AANLkTik0BOuDj5wmfHabZx_OzXDROtDLR2qtqUqQu4ko@mail.gmail.com>
 <AANLkTi=rOjHZt_F01UfunrTm=2r1BO5QGFDeV9XyKX4G@mail.gmail.com>
 <AANLkTimAnHcoVDY_p8PqZLMJdMz2w7bMnSbOwzn4aR4i@mail.gmail.com>
 <AANLkTimJsBYefz3+3HgBgrHUR33g+TWuBp15E=VODohb@mail.gmail.com>
 <AANLkTik1JJO7mqxPzqfshMfH2JFUXn+yxbTqVdr4QDf6@mail.gmail.com>
 <AANLkTi=7ETnRWOLRVAWhv=3BHZdzUnLvAqzxXOz399Xx@mail.gmail.com>
 <AANLkTi=D9Qw+Tw7wHb2T7UG_o9zkZcr2meHE3fwcMwvF@mail.gmail.com> <AANLkTimnKRDY8QLiJMMLqNzCA_-6UJmUDHKf-i1Yt3V5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Seblu <seblu@seblu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:63110 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933832Ab1CXTz3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 15:55:29 -0400
Received: by vxi39 with SMTP id 39so295373vxi.19
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2011 12:55:28 -0700 (PDT)
In-Reply-To: <AANLkTimnKRDY8QLiJMMLqNzCA_-6UJmUDHKf-i1Yt3V5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2011 at 5:58 AM, Seblu <seblu@seblu.net> wrote:
>> I don't necessarily disagree that there should be a better way to do
>> this, though as of the moment the above is probably your best bet.
>>
>> To me, the most important thing is to have consistent behavior acros=
s
>> different cards.
>
> Speaking of that, i've tryed =A02.6.38 on my station (dell opitplex 9=
80)
> to use the new bridging schema and it doesn't work.
> Exactly the case previously described: ip on br0 (eth0+eth1) and ip o=
n
> br0.42. eth0 driver is e1000e and eth1 is tg3. br0.42 don't receive
> traffic.
> I have to open a bug report?

The change was deliberate, not an accidental mistake, so don't expect
2.6.38 to suddenly switch back to the previous behavior.  There's no
need to file a bug report - the new behavior is known (I was the one
who changed it in the first place).  I will look into nicer semantics
in the future.
