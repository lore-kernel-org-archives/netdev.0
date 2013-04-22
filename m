From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v2] packet: tx timestamping on tpacket ring
Date: Mon, 22 Apr 2013 12:25:28 +0200
Message-ID: <51751018.2010305@redhat.com>
References: <CA+FuTSdGdhgpRARbv9zFnDESzCQBzT=DS-WgGZRWBLBvhN_sNg@mail.gmail.com> <1366408317-16432-1-git-send-email-willemb@google.com> <51728B32.4040200@redhat.com> <CA+FuTSckxSB-rDFVJbbWdxX=5HfNoD4vwkeHy71Ab2cam8wpGQ@mail.gmail.com> <5173BB0F.90900@redhat.com> <CA+FuTSc9ikN6gOsnKjM4Gv-2M+W-_jwijW4Wy=_RLLuRxoJw9A@mail.gmail.com> <5174F29C.2030806@onera.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>
To: Paul Chavent <Paul.Chavent@onera.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12615 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754370Ab3DVKZy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 06:25:54 -0400
In-Reply-To: <5174F29C.2030806@onera.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/2013 10:19 AM, Paul Chavent wrote:
> On 04/21/2013 06:42 PM, Willem de Bruijn wrote:
>> Tx has the advantage that time sources can be chosen
>> per socket independent of all other sockets
>
> Sorry if my question is trivial.
> I understand that when we require rx timestamping, we need to ask to the device to timestamp all incoming packets since we don't know the path of the packet in advance.
> For tx timestamping, you seems to say that the request to timestamp the packet is contained in the skbuff and is done on a per packet basis ?

It's all in: Documentation/networking/timestamping.txt
