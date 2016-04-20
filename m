From: Francesco Ruggeri <fruggeri@arista.com>
Subject: Re: [PATCH net-next] macvlan: fix failure during registration
Date: Tue, 19 Apr 2016 18:13:36 -0700
Message-ID: <CA+HUmGhvL=0bcRxUDR200BLr8mLjkFZstoUoW8UYV0LN4T+Vog@mail.gmail.com>
References: <1460992811-46992-1-git-send-email-fruggeri@arista.com>
	<87ega2sqhf.fsf@x220.int.ebiederm.org>
	<CA+HUmGhUqXn35x6Nnhcrk+WH8PuiaxwsrZNy-NsJ94wybCukGA@mail.gmail.com>
	<87wpnur4a4.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Mahesh Bandewar <maheshb@google.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:34134 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715AbcDTBNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 21:13:37 -0400
Received: by mail-oi0-f42.google.com with SMTP id k142so26801119oib.1
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 18:13:37 -0700 (PDT)
In-Reply-To: <87wpnur4a4.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 18, 2016 at 2:33 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> But please see if you can get macvlan_init to do the necessary work.
> That should simplify everything, and make clever games unnecessary.

Using macvlan_init seems to work. I will test it a couple of days and
then resubmit.

Thanks,
Francesco

>
> Eric
