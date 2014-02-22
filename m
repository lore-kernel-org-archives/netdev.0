From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v5 4/9] xen-netback: Change RX path for mapped
 SKB fragments
Date: Sat, 22 Feb 2014 23:18:41 +0000
Message-ID: <53093051.9040907@citrix.com>
References: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>	 <1390253069-25507-5-git-send-email-zoltan.kiss@citrix.com> <1392745532.23084.65.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:10284 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745AbaBVXSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 18:18:46 -0500
In-Reply-To: <1392745532.23084.65.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/02/14 17:45, Ian Campbell wrote:
> On Mon, 2014-01-20 at 21:24 +0000, Zoltan Kiss wrote:
>
> Re the Subject: change how? Perhaps "handle foreign mapped pages on the
> guest RX path" would be clearer.
Ok, I'll do that.

>
>> RX path need to know if the SKB fragments are stored on pages from another
>> domain.
> Does this not need to be done either before the mapping change or at the
> same time? -- otherwise you have a window of a couple of commits where
> things are broken, breaking bisectability.
I can move this to the beginning, to keep bisectability. I've put it 
here originally because none of these makes sense without the previous 
patches.

Zoli
