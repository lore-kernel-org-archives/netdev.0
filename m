From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 1/1] TCP: increase default initial receive window.
Date: Mon, 20 Dec 2010 10:26:20 -0800
Message-ID: <4D0F9FCC.7010108@hp.com>
References: <1292642451-892-1-git-send-email-nanditad@google.com>	<20101217.211309.226761639.davem@davemloft.net>	<AANLkTimSH_NfX2qno7sO3A4CHLsONmRUDHzWXY4reD28@mail.gmail.com> <20101220090352.3ea7ade2@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nandita Dukkipati <nanditad@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, chavey@google.com, ycheng@google.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:28823 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932742Ab0LTS0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 13:26:24 -0500
In-Reply-To: <20101220090352.3ea7ade2@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Agree this is a good idea, but some further notes:
>   * The control of receive window is a local function not covered by
>     RFC.
>   * Linux manipulates receive window automatically, unlike some other
>     implementations.
> 
> But any change to TCP risks breaking other broken implementations
> and users need a good way to recover. 

Always good to be careful, but break in what way?  Many stacks have been 
advertising an initial receive window of well above 10 segments going back 
literally decades.

HP-UX systems have been advertising a default/initial recieve window of 32768 
bytes since the mid 1990s, Solaris systems have been advertising a default 
receive window of 49152 for ages.  I cannot speak to Windows' default advertised 
window.  While that sound a bit like "But MOM! All my friends are doing it." it 
does seem to suggest that advertising an initial receive window of 10 segments 
is unlikely to uncover anything new.

rick jones
