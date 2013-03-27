From: Fernando Luis Vazquez Cao <fernando_b1-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 1/2] man/send(2): add EPERM to the list of possible errors
Date: Wed, 27 Mar 2013 13:14:49 +0900
Message-ID: <51527239.5070505@lab.ntt.co.jp>
References: <1363675513.4767.6.camel@nexus> <51515E5E.7020309@lab.ntt.co.jp> <20130326104833.GA5331@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Hirotaka Sasaki <sasaki.hirotaka-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
To: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130326104833.GA5331@localhost>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Pablo,

On 2013/03/26 19:48, Pablo Neira Ayuso wrote:
> On Tue, Mar 26, 2013 at 05:37:50PM +0900, Fernando Luis Vazquez Cao wrote:
>> Hi Michael,
>>
>> Do you see any problem with these two patches?
> Please, hold on with the second patch.

Are you Ok with getting patch 1 merged while be discuss
what to do about the issue that the second patch tried to
document? Could I get your "Acked-by" for it?


> I'd like to find a possible solution for the EPERM problem that we've
> been discussing. It requires some rework and performance evaluation.

The problem is that there is a huge installed base of
systems that show this broken behaviour, so even if
we find a proper fix for it we still should document
which systems may be affected by the spurious EPERM
bug, thus giving application programmers a chance to
add logic to their programs to recover from such
eventualities.


Regards,
Fernando
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
