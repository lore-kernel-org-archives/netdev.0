From: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Subject: Re: [PATCH 2/5] stmmac: pci: use managed resources
Date: Wed, 12 Nov 2014 10:44:00 +0530
Message-ID: <CAJ3bTp79FLhOCvvQNG=+C17v5TOzy2ZvbyC24OQWTr2mmJ4OCw@mail.gmail.com>
References: <1413909333-16380-1-git-send-email-andriy.shevchenko@linux.intel.com>
	<1413909333-16380-3-git-send-email-andriy.shevchenko@linux.intel.com>
	<5446C827.2040801@cogentembedded.com>
	<1413966993.2396.26.camel@linux.intel.com>
	<544E6486.6040502@st.com>
	<1414656349.2396.70.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev <netdev@vger.kernel.org>,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:52077 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbaKLFOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 00:14:01 -0500
Received: by mail-qc0-f172.google.com with SMTP id i17so8744576qcy.17
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 21:14:00 -0800 (PST)
In-Reply-To: <1414656349.2396.70.camel@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy,

Yes, I tested this pci driver on XILINX FPGA setup and its true that
we can man any bar number by changing the configuration in bit-map.

But its always good to keep that for loop which try to map any bar
number between 0 - 5, the new code breaks if bar number is other than
zero.

We can make driver generic by keeping that loop.

wwr
Rayagond

On Thu, Oct 30, 2014 at 1:35 PM, Andy Shevchenko
<andriy.shevchenko@linux.intel.com> wrote:
> On Mon, 2014-10-27 at 16:28 +0100, Giuseppe CAVALLARO wrote:
>> On 10/22/2014 10:36 AM, Andy Shevchenko wrote:
>> > So, I was trying to find any specification on public regarding to boards
>> > that have this IP, no luck so far. I guess that that code was created
>> > due to XILINX FPGA usage which probably can provide any BAR user wants
>> > to. Thus, I imply that in real applications the BAR most probably will
>> > be 0. However, I left variable which can be overridden in future
>> > (regarding to PCI ID).
>> >
>> > It would be nice to hear someone from ST about this. Giuseppe?
>>
>> Hello Andy
>>
>> this chip is on ST SoCs since long time but embedded. I have no PCI
>> card. Added Rayagond on copy too
>
> Rayagond, what do you think about changing an approach that is used to
> get resources from PCI?
>
> --
> Andy Shevchenko <andriy.shevchenko@intel.com>
> Intel Finland Oy
>
