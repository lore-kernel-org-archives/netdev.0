From: Paul Chavent <Paul.Chavent@onera.fr>
Subject: Re: [PATCH net-next v2] packet: tx timestamping on tpacket ring
Date: Mon, 22 Apr 2013 10:19:40 +0200
Message-ID: <5174F29C.2030806@onera.fr>
References: <CA+FuTSdGdhgpRARbv9zFnDESzCQBzT=DS-WgGZRWBLBvhN_sNg@mail.gmail.com> <1366408317-16432-1-git-send-email-willemb@google.com> <51728B32.4040200@redhat.com> <CA+FuTSckxSB-rDFVJbbWdxX=5HfNoD4vwkeHy71Ab2cam8wpGQ@mail.gmail.com> <5173BB0F.90900@redhat.com> <CA+FuTSc9ikN6gOsnKjM4Gv-2M+W-_jwijW4Wy=_RLLuRxoJw9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from briaree.onecert.fr ([134.212.190.4]:47177 "EHLO
	briaree.onecert.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755746Ab3DVIYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 04:24:11 -0400
In-Reply-To: <CA+FuTSc9ikN6gOsnKjM4Gv-2M+W-_jwijW4Wy=_RLLuRxoJw9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/21/2013 06:42 PM, Willem de Bruijn wrote:
> Tx has the advantage that time sources can be chosen
> per socket independent of all other sockets

Sorry if my question is trivial.
I understand that when we require rx timestamping, we need to ask to the 
device to timestamp all incoming packets since we don't know the path of 
the packet in advance.
For tx timestamping, you seems to say that the request to timestamp the 
packet is contained in the skbuff and is done on a per packet basis ?
