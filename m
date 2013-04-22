From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v2] packet: tx timestamping on tpacket ring
Date: Mon, 22 Apr 2013 10:23:24 -0400
Message-ID: <CA+FuTScyBjKp00G-EQA2j0WCn5e8S0QakMUeTPKF5TPi7YjQ3g@mail.gmail.com>
References: <CA+FuTSdGdhgpRARbv9zFnDESzCQBzT=DS-WgGZRWBLBvhN_sNg@mail.gmail.com>
 <1366408317-16432-1-git-send-email-willemb@google.com> <51728B32.4040200@redhat.com>
 <CA+FuTSckxSB-rDFVJbbWdxX=5HfNoD4vwkeHy71Ab2cam8wpGQ@mail.gmail.com>
 <5173BB0F.90900@redhat.com> <CA+FuTSc9ikN6gOsnKjM4Gv-2M+W-_jwijW4Wy=_RLLuRxoJw9A@mail.gmail.com>
 <5174F29C.2030806@onera.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>
To: Paul Chavent <Paul.Chavent@onera.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:35512 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827Ab3DVOXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 10:23:55 -0400
Received: by mail-ie0-f174.google.com with SMTP id 10so7152738ied.33
        for <netdev@vger.kernel.org>; Mon, 22 Apr 2013 07:23:55 -0700 (PDT)
In-Reply-To: <5174F29C.2030806@onera.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 22, 2013 at 4:19 AM, Paul Chavent <Paul.Chavent@onera.fr> wrote:
>
>
> On 04/21/2013 06:42 PM, Willem de Bruijn wrote:
>>
>> Tx has the advantage that time sources can be chosen
>> per socket independent of all other sockets
>
>
> Sorry if my question is trivial.
> I understand that when we require rx timestamping, we need to ask to the
> device to timestamp all incoming packets since we don't know the path of the
> packet in advance.
> For tx timestamping, you seems to say that the request to timestamp the
> packet is contained in the skbuff and is done on a per packet basis ?

Yes. More precisely, this is set using a socket option and applies to
all packets on that socket sent since the last update of the socket
option.
