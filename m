From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 2/2] bonding: debugfs and network namespaces are incompatible
Date: Tue, 10 Jul 2012 10:36:12 -0700
Message-ID: <15459.1341941772@death.nxdomain>
References: <20120706194741.GA22113@mail.hallyn.com> <87y5ms3bfi.fsf_-_@xmission.com> <87sjd03bdw.fsf_-_@xmission.com> <20120709.144932.243254122059983829.davem@davemloft.net>
Cc: ebiederm@xmission.com, dilip.daya@hp.com,
	linux-kernel@vger.kernel.org,
	containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	serge@hallyn.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <20120709.144932.243254122059983829.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

>From: ebiederm@xmission.com (Eric W. Biederman)
>Date: Mon, 09 Jul 2012 13:52:43 -0700
>
>> 
>> The bonding debugfs support has been broken in the presence of network
>> namespaces since it has been added.  The debugfs support does not handle
>> multiple bonding devices with the same name in different network
>> namespaces.
>> 
>> I haven't had any bug reports, and I'm not interested in getting any.
>> Disable the debugfs support when network namespaces are enabled.
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>
>Applied.

	Since distro kernels appear to set CONFIG_NET_NS, doesn't this
effectively disable debugfs for bonding on most distros?

	Do the other network device drivers that support debugfs have a
similar problem?  E.g., if each of two namespaces have an skge device
with the same name, will there be a debugfs conflict there as well?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
