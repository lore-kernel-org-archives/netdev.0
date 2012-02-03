From: Laszlo Ersek <lersek@redhat.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: correct	MAX_TX_TARGET	calculation.
Date: Fri, 03 Feb 2012 14:39:42 +0100
Message-ID: <4F2BE39E.9030101@redhat.com>
References: <1327598603-16398-1-git-send-email-wei.liu2@citrix.com>	<20120126181900.GB25572@phenom.dumpdata.com>	<1327660589.2585.14.camel@leeni.uk.xensource.com>	<4F2BD2CC.4050906@redhat.com> <4F2BDA4C.7060601@redhat.com> <4F2BEEA70200007800070E81@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeremy@goop.org" <jeremy@goop.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51500 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756109Ab2BCNiV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Feb 2012 08:38:21 -0500
In-Reply-To: <4F2BEEA70200007800070E81@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/12 14:26, Jan Beulich wrote:
>>>> On 03.02.12 at 13:59, Laszlo Ersek<lersek@redhat.com>  wrote:

>> (Eyeballing the source makes me think
>>
>>     NET_TX_RING_SIZE == (4096 - 16 - 48) / (5 * 4) == 201
>>     NET_RX_RING_SIZE == (4096 - 16 - 48) / (4 * 4) == 252
>
> NET_TX_RING_SIZE == (4096 - 16 - 48) / (6 * 2) == 336
> NET_RX_RING_SIZE == (4096 - 16 - 48) / (4 * 2) == 504

Sorry, I wasn't sure if gcc would pack them without 
__attribute__((packed)) :) Dumb mistake, admittedly.

Thanks,
Laszlo
