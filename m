From: Martin Tessun <martin.tessun-KuiJ5kEpwI6ELgA04lAiVw@public.gmane.org>
Subject: Re: Machine hard lock
Date: Fri, 23 Dec 2005 08:59:27 +0100
Message-ID: <43ABAE5F.5010403@freenet.de>
References: <20051222075903.3E196429EA9@mognix.dark-green.com>	 <1135271149.8765.0.camel@localhost>	 <43AAE710.90502@mtessun.dyndns.org>	 <200512221905.56663.mbuesch@freenet.de> <39e6f6c70512221209p24ed3543u5e8d09d9a6c5b13@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mbuesch-KuiJ5kEpwI6ELgA04lAiVw@public.gmane.org>, martin.tessun-xUmxicX565+Z9vWoFJJngh2eb7JE58TQ@public.gmane.org,
   netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
In-Reply-To: <39e6f6c70512221209p24ed3543u5e8d09d9a6c5b13-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo wrote:
> On 12/22/05, Michael Buesch <mbuesch-KuiJ5kEpwI6ELgA04lAiVw@public.gmane.org> wrote:
>> On Thursday 22 December 2005 18:49, Martin Tessun wrote:
>>> Johannes Berg wrote:
>>>> On Thu, 2005-12-22 at 17:51 +0100, Martin Tessun wrote:
>>>>
>>>>> At least you get them inserted ;) When I try to modprobe rate_control I
>>>>> get the following:
>>>> insmod 80211 first.
>>>>
>>>> johannes
>>> No, this ist not the problem.
>>> When inserting 80211 I get the same message;
>>>
>>> kernel: 80211: ieee80211_tx_packet_data is bigger than the skb->cb (48 >
>>> 40)
>>>
>>> And *this* is the real problem. The two structs don't match somehow.
>> You're on a 64bit machine.
>> Run a 32bit kernel, or wait a few weeks until this is fixed.
> 
> Or temporarily increase the size of struct sk_buff::cb from [40] to
> [48] if he wants to test other features present in this kernel release
> he is trying to compile.

Great. now it works ;) I can do some more tests now...
(Sometimes it is helpful to read the docs of tcp.h ;)

Thanks for that workaround.

Regards,
Martin
