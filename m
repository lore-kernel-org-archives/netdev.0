From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 6/7] net: ixgbe: add minimal parser details for ixgbe
Date: Tue, 02 Feb 2016 08:46:44 -0800
Message-ID: <56B0DD74.1090806@gmail.com>
References: <20160201014555.13871.56591.stgit@john-Precision-Tower-5810>	<20160201015238.13871.81573.stgit@john-Precision-Tower-5810> <CAJ3xEMi_4N-x=_jKaJ8_f2BxHhrhhiCuftwzmqNZaiGv_d1c9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>, ast@fb.com,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	horms@verge.net.au, Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33945 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756308AbcBBQrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 11:47:01 -0500
Received: by mail-pa0-f53.google.com with SMTP id uo6so103578751pac.1
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 08:47:01 -0800 (PST)
In-Reply-To: <CAJ3xEMi_4N-x=_jKaJ8_f2BxHhrhhiCuftwzmqNZaiGv_d1c9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-02 08:27 AM, Or Gerlitz wrote:
> On Mon, Feb 1, 2016 at 3:52 AM, John Fastabend <john.fastabend@gmail.com> wrote:
>> This adds an ixgbe data structure that is used to determine what
>> headers:fields can be matched and in what order they are supported.
>>
>> For hardware devices this can be a bit tricky because typically
>> only pre-programmed (firmware, ucode, rtl) parse graphs will be
>> supported and we don't yet have an interface to change these from
>> the OS. So its sort of a you get whatever your friendly vendor
>> provides affair at the moment.
>>
>> In the future we can add the get routines and set routines to
>> update this data structure. One interesting thing to note here
>> is the data structure here identifies ethernet, ip, and tcp
>> fields without having to hardcode them as enumerations or use
>> other identifiers.
> 
> Maybe for the current state this patch (or the most of it) can be
> made generic and provided in a way that  multiple HW drivers can use it?
> 

If you want the structs we can put them in a helper lib but the
main code is two for loops to catch the keys and an if block to catch
the nexthdr code mixed with a bunch of code to program the specific
device. Its just not that helpful to other drivers.

.John
