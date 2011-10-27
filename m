From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: [PATCH] Add TCP_NO_DELAYED_ACK socket option
Date: Thu, 27 Oct 2011 15:18:35 +0300
Message-ID: <CAEnQRZAbpXZh9GA_XXwXhymKxwB7tO4+m5E8ZDAz+mN4cPEMhg@mail.gmail.com>
References: <fc8b00b9978b4f956fa705badfaa138854abf919.1319595687.git.luto@amacapital.net>
	<1319711072.2601.18.camel@edumazet-laptop>
	<CAEnQRZAmDMg943uufpwf4dj0vw9hfsRu3RFRG+LEqfT2Y0ty1Q@mail.gmail.com>
	<1319717597.2601.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Lutomirski <luto@amacapital.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:44697 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755289Ab1J0MSf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 08:18:35 -0400
Received: by qyk4 with SMTP id 4so656351qyk.19
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2011 05:18:35 -0700 (PDT)
In-Reply-To: <1319717597.2601.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 27, 2011 at 3:13 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 27 octobre 2011 =E0 14:54 +0300, Daniel Baluta a =E9crit :
>
>> Few days ago, in our custom kernel we made TCP Delack segments and
>> TCP Delack timeout parameters tunable via proc entries.
>> Increasing tcp_delack_segs (number of full sized segments that must
>> be received until an ACK is sent) we observed an improvement of
>> throughput up to 20% in some test cases.
>>
>> Do you think that this kind of patch would have a chance to be
>> included in mainstream?
>>
>
> If your patches are ready, why not sending them as RFC ?

OK, I will port them to the latest kernel and send a patch.

thanks,
Daniel.
