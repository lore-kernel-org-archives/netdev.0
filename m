From: Paul Chavent <Paul.Chavent@onera.fr>
Subject: Re: [PATCH] net-packet: tx timestamping on tpacket ring
Date: Mon, 15 Apr 2013 09:37:30 +0200
Message-ID: <516BAE3A.5020508@onera.fr>
References: <CA+FuTSezggEb7znDYMf8vWU7JmWLP59AVPkaTvNaAwJoNcqk9A@mail.gmail.com> <1365879412-9541-1-git-send-email-willemb@google.com> <5169D9C8.8010504@redhat.com> <CA+FuTSe1KCPPW=FBXZoTNmri9oPHicuoFeEMKws09PwbyRe-2A@mail.gmail.com> <516A8A60.5020003@redhat.com> <20130414130726.GB2871@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from briaree.onecert.fr ([134.212.190.4]:32969 "EHLO
	briaree.onecert.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541Ab3DOHly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 03:41:54 -0400
In-Reply-To: <20130414130726.GB2871@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/14/2013 03:07 PM, Richard Cochran wrote:
> On Sun, Apr 14, 2013 at 12:52:16PM +0200, Daniel Borkmann wrote:
>>
>> While going a bit more through the code, I'm wondering .. if we want to support
>> TX timestamps, could we also support SW _and_ HW timestamps e.g. similar as in
>> sock_recv_timestamp()? I'm asking, because we already allow setting the flags
>> for it via sock_tx_timestamp(). This might be good, if possible.
>
> And while you are at it, you could also fix the receive code.
>
> As it stand now, it is fairly useless, since there is no way for user
> space to tell which kind of time stamp has been reported. In fact, the
> code will silently intermingle hardware and software time stamps. That
> is surely a mean trick to play on the users.

Isn't it the one that the user ask with setsockopt(fd, SOL_PACKET, 
PACKET_TIMESTAMP, &timestamping, sizeof(timestamping)) ?

However, i wonder why you added an other sockopt that do the same thing 
as SOL_SOCKET/SO_TIMESTAMPING sockopt ?

Paul.
