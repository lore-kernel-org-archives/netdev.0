From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pci: push deprecated pci_find_device() function to
 last user
Date: Thu, 14 Jan 2010 00:12:04 -0800 (PST)
Message-ID: <20100114.001204.203918209.davem@davemloft.net>
References: <20100113142328.5DE2F40107@xenon.ts.pxnet.com>
	<20100113.203338.52448956.davem@davemloft.net>
	<20100114044331.GA29008@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tilman@imap.cc, sfr@canb.auug.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, isdn@linux-pingi.de,
	isdn4linux@listserv.isdn4linux.de
To: gregkh@suse.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756457Ab0ANIL5@vger.kernel.org>
In-Reply-To: <20100114044331.GA29008@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg KH <gregkh@suse.de>
Date: Wed, 13 Jan 2010 20:43:31 -0800

> On Wed, Jan 13, 2010 at 08:33:38PM -0800, David Miller wrote:
>> From: Tilman Schmidt <tilman@imap.cc>
>> Date: Wed, 13 Jan 2010 15:23:28 +0100 (CET)
>> 
>> > The ISDN4Linux HiSax driver family contains the last remaining users
>> > of the deprecated pci_find_device() function. This patch creates a
>> > private copy of that function in HiSax, and removes the now unused
>> > global function together with its controlling configuration option,
>> > CONFIG_PCI_LEGACY.
>> > 
>> > Impact: code reorganization, no functional change
>> > Signed-off-by: Tilman Schmidt <tilman@imap.cc>
>> > ---
>> > Note: This patch is not, nor does it intend to be, checkpatch.pl clean.
>> > The issues checkpatch.pl reports on it were already present before, and
>> > are unrelated to the topic of this patch.
>> 
>> I'm fine with this, and Greg or whoever else can take this
>> through a driver or PCI specific tree if they want:
>> 
>> Acked-by: David S. Miller <davem@davemloft.net>
> 
> Where do ISDN patches go through, the network tree?
> 
> Acked-by: Greg Kroah-Hartman <gregkh@suse.de>

Yeah usually, but I thought the PCI tree might want this one
because it tosses things from drivers/pci
