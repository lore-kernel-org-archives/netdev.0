From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: PATCH: [SKBUFF] introduce skb_link_header_size(skb)
Date: Tue, 05 Oct 2004 16:45:33 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4162F9DD.2070705@conectiva.com.br>
References: <4162F28B.2050308@conectiva.com.br> <20041005193352.GA19714@rei.reeler.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041005193352.GA19714@rei.reeler.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Thomas Graf wrote:
> * Arnaldo Carvalho de Melo <4162F28B.2050308@conectiva.com.br> 2004-10-05 16:14
> 
>>+static inline int skb_link_header_size(const struct sk_buff *skb)
>>+{
>>+	return skb->nh.raw - skb->mac.raw;
>>+}
> 
> 
> The patch is valid and I think it is right to do so but this may lead to
> wrong results when skb->mac.raw is set to 0x0 F.e in classifiers. Maybe
> add a comment to warn about it?

I never looked at classifiers code, suggest a comment and I'll stick it
there.

Thanks for commenting on the patch.

Regards,

- Arnaldo
