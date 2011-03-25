From: Seblu <seblu@seblu.net>
Subject: Re: bnx2 vlan issue
Date: Fri, 25 Mar 2011 01:26:47 +0100
Message-ID: <AANLkTi=gsP3ZZyEwO+CcM3uB6G5-QswYEfqdtiy8oOyv@mail.gmail.com>
References: <AANLkTik0BOuDj5wmfHabZx_OzXDROtDLR2qtqUqQu4ko@mail.gmail.com>
 <AANLkTi=rOjHZt_F01UfunrTm=2r1BO5QGFDeV9XyKX4G@mail.gmail.com>
 <AANLkTimAnHcoVDY_p8PqZLMJdMz2w7bMnSbOwzn4aR4i@mail.gmail.com>
 <AANLkTimJsBYefz3+3HgBgrHUR33g+TWuBp15E=VODohb@mail.gmail.com>
 <AANLkTik1JJO7mqxPzqfshMfH2JFUXn+yxbTqVdr4QDf6@mail.gmail.com>
 <AANLkTi=7ETnRWOLRVAWhv=3BHZdzUnLvAqzxXOz399Xx@mail.gmail.com>
 <AANLkTi=D9Qw+Tw7wHb2T7UG_o9zkZcr2meHE3fwcMwvF@mail.gmail.com>
 <AANLkTimnKRDY8QLiJMMLqNzCA_-6UJmUDHKf-i1Yt3V5@mail.gmail.com> <AANLkTi=zfhwHTB7kitgwk3AzSa0aFFyxgM_ZY-3wObR5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:58618 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136Ab1CYA1I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 20:27:08 -0400
Received: by qwk3 with SMTP id 3so326514qwk.19
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2011 17:27:07 -0700 (PDT)
In-Reply-To: <AANLkTi=zfhwHTB7kitgwk3AzSa0aFFyxgM_ZY-3wObR5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2011 at 8:55 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Thu, Mar 24, 2011 at 5:58 AM, Seblu <seblu@seblu.net> wrote:
>>> I don't necessarily disagree that there should be a better way to d=
o
>>> this, though as of the moment the above is probably your best bet.
>>>
>>> To me, the most important thing is to have consistent behavior acro=
ss
>>> different cards.
>>
>> Speaking of that, i've tryed =A02.6.38 on my station (dell opitplex =
980)
>> to use the new bridging schema and it doesn't work.
>> Exactly the case previously described: ip on br0 (eth0+eth1) and ip =
on
>> br0.42. eth0 driver is e1000e and eth1 is tg3. br0.42 don't receive
>> traffic.
>> I have to open a bug report?
>
> The change was deliberate, not an accidental mistake, so don't expect
> 2.6.38 to suddenly switch back to the previous behavior. =A0There's n=
o
> need to file a bug report - the new behavior is known (I was the one
> who changed it in the first place). =A0I will look into nicer semanti=
cs
> in the future.
>
Maybe i was not enough clear. It seems to me that new behaviour, with
vlan on top of bridge rather than above interface in bridge is not
functional.
In other words, i cannot use vlan and bridge together in 2.6.38 (with e=
1000e).

I understand hard works are in progress and old behaviour will maybe
disapear forever. Here i just don't use vlan and bridge like you
suggest me in your previous post.


--=20
S=E9bastien Luttringer
www.seblu.net
