From: Kyle Moffett <mrmacman_g4@mac.com>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation [try #2]
Date: Sat, 17 Mar 2007 23:32:17 -0700
Message-ID: <076F1B35-BE08-41B4-8294-581EDAFF4ACC@mac.com>
References: <20070316153408.3a9a244a@lxorguk.ukuu.org.uk> <20070316151305.04cbc352@lxorguk.ukuu.org.uk> <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com> <25571.1174054993@redhat.com> <26525.1174058071@redhat.com> <20070316171141.7a4de504@lxorguk.ukuu.org.uk>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Howells <dhowells@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753081AbXCRGdM@vger.kernel.org>
In-Reply-To: <20070316171141.7a4de504@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mar 16, 2007, at 10:11:41, Alan Cox wrote:
>> I know what they are; and I don't think that what's available  
>> covers it.
>>
>>> and use a proper standard socket type.
>>
>> Assuming that that list is exhaustive...
>
> SOCK_RDM seems to match perfectly well here. The point isn't to  
> enumerate everything in the universe the point is to find "works  
> like" parallels good enough to avoid more special casing.

IMHO the problem with classifying RxRPC as a "reliable datagram"  
socket is that even an atomic unidirectional communication isn't a  
single datagram, it's at least 3; there is shared connection state  
and security context on both sides which pertains to a collection of  
independent and possibly simultaneous RxRPC calls.  From the digging  
around that I did in the kernel socket code a while ago I don't see a  
cleaner way of implementing it than a new SOCK_RXRPC.

Cheers,
Kyle Moffett
