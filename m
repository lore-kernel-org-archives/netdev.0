From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 2/2] net: Use Toeplitz for IPv4 and IPv6 connection hashing
Date: Mon, 23 Sep 2013 16:26:02 -0700
Message-ID: <CA+mtBx_4u0xi0eqQ1H4Vn=GmFgppbgMWz8SypYD6dpoD+Dxk_g@mail.gmail.com>
References: <alpine.DEB.2.02.1309231543330.23714@tomh.mtv.corp.google.com>
	<20130923161115.5d756838@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:59091 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752849Ab3IWX0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 19:26:03 -0400
Received: by mail-ie0-f182.google.com with SMTP id aq17so7724906iec.13
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 16:26:02 -0700 (PDT)
In-Reply-To: <20130923161115.5d756838@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 23, 2013 at 4:11 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Mon, 23 Sep 2013 15:44:51 -0700 (PDT)
> Tom Herbert <therbert@google.com> wrote:
>
>> Toeplitz
>>   IPv4
>>     58.72% CPU utilization
>>     110/146/198 90/95/99% latencies
>>     1.72549e+06 tps
>>   IPv6
>>     72.38% CPU utilization
>>     117/168/255 90/95/99% latencies
>>     1.58545e+06 tps
>>
>> Jhash
>>   IPv4
>>     57.67% CPU utilization
>>     111/146/196 90/95/99% latencies
>>     1.71574e+06 tps
>>   IPv6
>>     71.84% CPU utilization
>>     117/166/248 90/95/99% latencies
>>     1.59359e+06 tps
>
> It looks slower and more complex than Jhash, what is the benefit?
> Have you investigated using Murmur instead?

Benefit would be to leverage and be compatible HW hash computation...
perhaps this is just an intellectual curiosity :-)
