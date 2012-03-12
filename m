From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH 1/2] net/hyperv: Fix data corruption in
 rndis_filter_receive()
Date: Mon, 12 Mar 2012 15:39:02 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DCE4044@TK5EX14MBXC223.redmond.corp.microsoft.com>
References: <1331328437-26852-1-git-send-email-haiyangz@microsoft.com>
 <20120311.155111.1595145426893784653.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: KY Srinivasan <kys@microsoft.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120311.155111.1595145426893784653.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Sunday, March 11, 2012 6:51 PM
> To: Haiyang Zhang
> Cc: KY Srinivasan; netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org
> Subject: Re: [PATCH 1/2] net/hyperv: Fix data corruption in
> rndis_filter_receive()
> 
> 
> It is very tiring explaining how to submit patches properly, and here you've
> made a poor submission once again.
> 
> You haven't indicated what tree you want these changes applied to.
> 
> You also mixed bug fixes and feature patches into the same patch set.
> 
> So the patch set isn't appropriate for the 'net' tree, because only the most
> critical bug fixes can go there now.
> 
> And this patch set is also not appropriate for the 'net-next' tree because I can
> only presume you want the important bug fix propagated upstream as fast as
> possible but it cannot go in with the feature patch since the feature patch is
> absolutely not appropriate for the 'net' tree right now.
> 
> I really don't see why it's such a hard thing to simply say where you want
> patches applied when you submit them.  Do you want me to simply guess?
> How else am I supposed to figure out what you want?

I want both patches go to the 'net-next' tree. The patch [1/2] is required by the 
vlan trunking feature [2/2]. So they should go together.

The bug in rndis_filter_receive() does NOT happen until we start to use 
'per-packet-data' by the vlan trunking feature, so the bug fix [1/2] isn't urgent 
to be applied into 'net' tree.

And, thanks for the reminder, I will specify the target tree in future submissions.

Thanks,
- Haiyang
