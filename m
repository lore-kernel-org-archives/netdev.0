From: David Miller <davem@davemloft.net>
Subject: Re: [Xen-devel] [PATCH] xen: netback: remove redundant xenvif_put
Date: Tue, 19 Feb 2013 13:06:07 -0500 (EST)
Message-ID: <20130219.130607.100487415380997622.davem@davemloft.net>
References: <20130219.005356.2288460992654639558.davem@davemloft.net>
	<51233FF502000078000BF4AE@nat28.tlf.novell.com>
	<1361264324.1051.61.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: JBeulich@suse.com, drjones@redhat.com,
	xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Ian.Campbell@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1361264324.1051.61.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Tue, 19 Feb 2013 08:58:44 +0000

> On Tue, 2013-02-19 at 08:03 +0000, Jan Beulich wrote:
>> >>> On 19.02.13 at 06:53, David Miller <davem@davemloft.net> wrote:
>> > From: Andrew Jones <drjones@redhat.com>
>> > Date: Mon, 18 Feb 2013 21:29:20 +0100
>> > 
>> >> netbk_fatal_tx_err() calls xenvif_carrier_off(), which does
>> >> a xenvif_put(). As callers of netbk_fatal_tx_err should only
>> >> have one reference to the vif at this time, then the xenvif_put
>> >> in netbk_fatal_tx_err is one too many.
>> >> 
>> >> Signed-off-by: Andrew Jones <drjones@redhat.com>
>> > 
>> > Applied.
>> 
>> But this is wrong from all we can tell,
> 
> Yes, please can this be reverted.

Done and I've annotated the revert commit message with as much
information as possible.
