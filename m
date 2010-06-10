From: Patrick McHardy <kaber@trash.net>
Subject: Re: no reassembly for outgoing packets on RAW socket
Date: Thu, 10 Jun 2010 11:14:04 +0200
Message-ID: <4C10ACDC.6010108@trash.net>
References: <20100604112708.GA1958@jolsa.lab.eng.brq.redhat.com> <4C08EB85.3050900@trash.net> <20100607145558.GA1939@jolsa.lab.eng.brq.redhat.com> <4C0FA24A.7060907@trash.net> <20100610065631.GA1915@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100610065631.GA1915@jolsa.lab.eng.brq.redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Olsa wrote:
> On Wed, Jun 09, 2010 at 04:16:42PM +0200, Patrick McHardy wrote:
>   
>>> If this is not the way, I'd appreciatte any hint..  my goal is
>>> to put malformed packet on the wire (more frags bit set for a
>>> non fragmented packet)
>>>       
>> I don't have any good suggestions besides adding a flag to the IPCB
>> and skipping defragmentation based on that.
>>     
> ok,
>
> I can see a way when I set this via setsockopt to the socket,
> and check the value before the defragmentation..  would such a new
> setsock option be acceptable?
>
> I'm not sure I can see a way via IPCB, AFAICS it's for skb bound flags
> which arise during the skb processing.
>   

Yes, a socket option is basically what I was suggesting, using the
IPCB to mark the packet. But just marking the socket is fine of
course.


