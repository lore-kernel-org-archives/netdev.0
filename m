From: Richard Alpe <richard.alpe@ericsson.com>
Subject: Re: [PATCH iproute2] tipc: introduce TIPC
	configuration tool
Date: Thu, 4 Jun 2015 13:40:47 +0200
Message-ID: <5570393F.9060401@ericsson.com>
References: <1431004056-6282-1-git-send-email-richard.alpe@ericsson.com>
	<20150521144340.1b112c0a@urahara>
	<1689829731.5883859.1433413415372.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: Pavel Simerda <psimerda@redhat.com>, Stephen Hemminger
	<stephen@networkplumber.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1689829731.5883859.1433413415372.JavaMail.zimbra@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 2015-06-04 12:23, Pavel Simerda wrote:
> ----- Original Message -----
>> From: "Stephen Hemminger" <stephen@networkplumber.org>
>> To: "richard alpe" <richard.alpe@ericsson.com>
>> Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
>> Sent: Thursday, May 21, 2015 11:43:40 PM
>> Subject: Re: [PATCH iproute2] tipc: introduce TIPC configuration tool
>>
>> On Thu, 7 May 2015 15:07:35 +0200
>> <richard.alpe@ericsson.com> wrote:
>>
>>> From: Richard Alpe <richard.alpe@ericsson.com>
>>>
>>> This is the new tipc tool that utilizes the relativly new TIPC netlink API
>>> in
>>> the kernel. Introducing this tool into iproute2 has been discussed
>>> previously.
>>>
>>> For more information about the design decisions of this tool, see the
>>> README
>>> file.
>>>
>>> There isn't yet a manpage for the this tool. I will start to write one once
>>> I
>>> submitted this for review.
>>>
>>> Richard Alpe (1):
>>>   tipc: add new TIPC configuration tool
>>
>> I went ahead and merged this.
>> It does add dependency on libmnl which the distribution maintainers will have
>> to add to their stuff.
> 
> Does the new dependency suggest the whole iproute2 is moving to libmnl?
That is what I was told and the reason I wrote "tipc" based on libmnl.

Regards
Richard

> Or is
> there a good reason to use an external netlink library as well as an internal one?
> 
> Cheers,
> 
> Pavel
> 
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>


------------------------------------------------------------------------------
