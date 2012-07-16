From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH 4/7] net-tcp: Fast Open client - receiving SYN-ACK
Date: Mon, 16 Jul 2012 16:33:36 -0700
Message-ID: <CAK6E8=c164c=EWtcs+S4QS73CitpjgtkWjDfWgWHjciiYuntvA@mail.gmail.com>
References: <1342473410-6265-1-git-send-email-ycheng@google.com>
 <1342473410-6265-5-git-send-email-ycheng@google.com> <CAGK4HS9iEVy6NEx_dJgdEW8P2K9_G0vhziE+7O7iW+6WFc3VEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com, sivasankar@cs.ucsd.edu,
	netdev@vger.kernel.org
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:37627 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308Ab2GPXd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 19:33:57 -0400
Received: by obbuo13 with SMTP id uo13so10194551obb.19
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 16:33:56 -0700 (PDT)
In-Reply-To: <CAGK4HS9iEVy6NEx_dJgdEW8P2K9_G0vhziE+7O7iW+6WFc3VEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 16, 2012 at 3:57 PM, Vijay Subramanian
<subramanian.vijay@gmail.com> wrote:
> On 16 July 2012 14:16, Yuchung Cheng <ycheng@google.com> wrote:
>> On receiving the SYN-ACK after SYN-data, the client needs to
>> a) update the cached MSS and cookie (if included in SYN-ACK)
>> b) retransmit the data yet acknowledged by the SYN-ACK in the final ACK of
>>    the handshake.
>
> I think you mean "data not yet acknowledged " in point (b).
yes "not yet". I will fix it in the next round after I collect more
reviews. Thanks!
>
> Vijay
