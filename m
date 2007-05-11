From: "Simon Arlott" <simon@fire.lp0.eu>
Subject: RE: Accessing certain web sites broken from 2.6.19+
Date: Fri, 11 May 2007 12:27:40 +0100
Message-ID: <29891.simon.1178882860@5ec7c279.invalid>
References: <4643efc2.7cb1b0b0.2a08.4658@mx.google.com>
    <7e63f56c0705102138q5a623fadm520473df49e49963@mail.gmail.com>
    <4643fc1e.095ef753.14ef.ffffb9a8@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "'Robert Iakobashvili'" <coroberti@gmail.com>,
	netdev@vger.kernel.org
To: "Andrew Hall" <andrew.a.hall@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:41759 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755927AbXEKL1n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 07:27:43 -0400
In-Reply-To: <4643fc1e.095ef753.14ef.ffffb9a8@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, May 11, 2007 06:16, Andrew Hall wrote:
>> -----Original Message-----
>> From: Robert Iakobashvili [mailto:coroberti@gmail.com]
>> Sent: Friday, 11 May 2007 2:38 PM
>> To: Andrew Hall
>> Cc: netdev@vger.kernel.org
>> Subject: Re: Accessing certain web sites broken from 2.6.19+
>>
>> On 5/11/07, Andrew Hall <andrew.a.hall@gmail.com> wrote:
>> > When accessing certain web sites when using any kernel above 2.6.19,
>> TCP
>> > seems to break. Connection to the site is established but never
>> completes.
>> > One particular site is www.dcita.gov.au. Is there a known issue
>> pertaining
>> > to this? Using any kernel below 2.6.19 (for example: 2.6.12 or
>> 2.6.15) works
>> > fine.
>>
>> Including 2.6.21?
>>
>> Which browser/s have you tried?
>>
>> --
>> Sincerely,
>> Robert Iakobashvili,
>> coroberti %x40 gmail %x2e com
>> ...........................................................
>> http://curl-loader.sourceforge.net
>> A web testing and traffic generation tool.
>
> I have not yet tried 2.6.21.. only tried to 2.6.20.9. The issue isn't
> browser dependent ,as a wget directly from the OS will also fail during the
> connection. Interestingly requests made from hosts behind the 2.6.20 gateway
> that make the same request work fine, it seems it's only requests made from
> the localhost itself.
>

Use tcptraceroute with and without -E to check this isn't a problem with ECN.


-- 
Simon Arlott
