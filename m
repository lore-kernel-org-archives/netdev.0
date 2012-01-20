From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: linux-next: Tree for Jan 19 (cisco/enic)
Date: Thu, 19 Jan 2012 21:45:22 -0800
Message-ID: <CB3E3F72.412F2%roprabhu@cisco.com>
References: <CB3E3CB9.412EA%roprabhu@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"Christian Benvenuti (benve)" <benve@cisco.com>
To: Roopa Prabhu <roprabhu@cisco.com>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <CB3E3CB9.412EA%roprabhu@cisco.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org




On 1/19/12 9:33 PM, "Roopa Prabhu" <roprabhu@cisco.com> wrote:

> 
> 
> 
> On 1/19/12 3:43 PM, "Randy Dunlap" <rdunlap@xenotime.net> wrote:
> 
>> On 01/18/2012 05:59 PM, Stephen Rothwell wrote:
>>> Hi all,
>>> 
>>> Changes since 20120118:
>> 
>> 
>> on x86_64:
>> 
>> /next/linux-next-20120119/drivers/net/ethernet/cisco/enic/enic_main.c: In
>> function 'enic_probe':
>> 
/next/linux-next-20120119/drivers/net/ethernet/cisco/enic/enic_main.c:2387:16>>
:
>> error: 'struct enic' has no member named 'num_vfs'
>> 
/next/linux-next-20120119/drivers/net/ethernet/cisco/enic/enic_main.c:2387:32>>
:
>> error: 'struct enic' has no member named 'num_vfs'
>> 
>> 
>> Full randconfig file is attached.
>> 
>> --
>> ~Randy
>> *** Remember to use Documentation/SubmitChecklist when testing your code ***
>> 
> Thanks for reporting stephen. Its because you don't have CONFIG_PCI_IOV
> enabled. I will working on the patch. Will submit soon.
> 
Actually thanks randy. Patch coming soon..

> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
