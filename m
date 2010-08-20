From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC Patch] netxen: remove firmware exports
Date: Fri, 20 Aug 2010 16:52:14 +0800
Message-ID: <4C6E423E.5080804@redhat.com>
References: <20100818095908.6606.56224.sendpatchset@localhost.localdomain> <99737F4847ED0A48AECC9F4A1974A4B80F86E69208@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Dhananjay Phadke <dhananjay.phadke@qlogic.com>,
	Narender Kumar <narender.kumar@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Amit Salecha <amit.salecha@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80F86E69208@MNEXMB2.qlogic.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/19/10 17:12, Amit Salecha wrote:
>> netxen_nic driver can store firmwares on flash, and get them porperly and
>> dynamically, so the firmwares may not appear in /lib/firmware/. However, netxen_nic
>> still exports these firmwares via modinfo, this makes our script which parses
>> modinfo output fail.
>
> NX_UNIFIED_ROMIMAGE_NAME(phanfw.bin) is already submitted and we won't submit any other fw files.
>
>> -MODULE_FIRMWARE(NX_P2_MN_ROMIMAGE_NAME);
>> -MODULE_FIRMWARE(NX_P3_CT_ROMIMAGE_NAME);
>> -MODULE_FIRMWARE(NX_P3_MN_ROMIMAGE_NAME);
>
> It's not compulsory to submit firmware files which are exported (MODULE_FIRMWARE).
> I am leaving this upto David to decide about this patch.
>

Okay. David, do you want me to submit an updated patch?

Thanks!

-- 
The opposite of love is not hate, it's indifference.
  - Elie Wiesel
