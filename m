From: Gabriel C <nix.or.die@googlemail.com>
Subject: Re: array subscript is above array bounds warnings with gcc4.3
Date: Fri, 04 Apr 2008 20:12:44 +0200
Message-ID: <47F66F9C.2060107@googlemail.com>
References: <47F665E6.2010409@googlemail.com> <20080404180509.GA1900@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Gabriel C <crazy@frugalware.org>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	linux-acpi@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20080404180509.GA1900@cs181133002.pp.htv.fi>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> On Fri, Apr 04, 2008 at 07:31:18PM +0200, Gabriel C wrote:
>> Hi,
>>
>> I noticed these warning on my randconfig logs of some builds :
>>
>> ..
>>
>> drivers/usb/core/hcd.c: In function 'usb_hcd_poll_rh_status':                                                                                                
>> include/asm/string_32.h:65: warning: array subscript is above array bounds
>>
>> net/netfilter/nf_conntrack_proto_sctp.c: In function 'sctp_packet':                                                                                          
>> net/netfilter/nf_conntrack_proto_sctp.c:374: warning: array subscript is above array bounds
>>
>> drivers/acpi/tables/tbfadt.c: In function 'acpi_tb_create_local_fadt':                                                                                       
>> include/asm/string_32.h:65: warning: array subscript is above array bounds
>>
>> ...
> 
> Sounds like a known and already fixed bug in gcc.
> 
> Can you confirm that they go away when you build your compiler from the 
> head of the gcc 4.3 SVN branch?
> 

I cannot do that right now but I'll build SVN 4.3 tomorrow and report back.

Gabriel

