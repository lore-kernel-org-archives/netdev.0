From: Steve Rago <sar@nec-labs.com>
Subject: Re: bug in passing file descriptors
Date: Wed, 9 Oct 2013 10:07:25 -0400
Message-ID: <5255631D.9010001@nec-labs.com>
References: <525308C4.1030007@nec-labs.com> <20131007.154226.533738557474978526.davem@davemloft.net> <5253199B.3000109@nec-labs.com> <20131007.173237.1669132001431607341.davem@davemloft.net> <87li24zo6x.fsf@tassilo.jf.intel.com> <52541769.1000306@nec-labs.com> <CALCETrVoUrcuzEx_TURoGE8_MJtZLOz-UDz6m69Vo6MCWG0zjg@mail.gmail.com> <52543065.7000209@nec-labs.com> <20131008164108.GO6882@two.firstfloor.org> <525437FF.5020905@nec-labs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@amacapital.net>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Michael Kerrisk-manpages <mtk.manpages@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nec-labs.com ([138.15.200.209]:42657 "EHLO
	mail.nec-labs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515Ab3JIOHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 10:07:46 -0400
In-Reply-To: <525437FF.5020905@nec-labs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/08/2013 12:51 PM, Steve Rago wrote:
> On 10/08/2013 12:41 PM, Andi Kleen wrote:
>>> I just want the semantics to be consistent.  If you want Linux to
>>> always require applications that call recvmsg to provide a buffer
>>> size of CMSG_SPACE bytes long to retrieve control information, then
>>> fail the system call when the buffer is smaller.  But if you do
>>> this, you risk breaking applications that work with FreeBSD, Mac OS
>>> X, Solaris, and probably a few others.
>>
>> The primary concern is to be binary compatible with Linux.

Not to application developers, by the way.

>>
>> But not being compatible between 32bit and 64bit Linux processes on the same
>> host would seem like a serious problem to me.
>>
>>> Regardless, copying 20 bytes and telling me you copied 24 is misleading and wrong.
>>
>> The question is could it break existing Linux applications to change it?
>> And would it help with the 32/64bit compatibility?
>>
>> If not some other way to fix the compat layer would need to be found.
>>
>> -Andi
>>
>
> I'm not sure if a 64-bit process and a 32-bit process exchange file descriptors on the same system has a problem.  It
> certainly looks like the compat code does the right thing.  I can test this tonight if you want.

I tested all combinations and they work fine as far as Linux binary compatibility is concerned.

Steve
