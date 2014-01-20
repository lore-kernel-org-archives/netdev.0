From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v4 1/9] xen-netback: Introduce TX grant map definitions
Date: Mon, 20 Jan 2014 16:53:35 +0000
Message-ID: <52DD548F.2060409@citrix.com>
References: <1389731995-9887-1-git-send-email-zoltan.kiss@citrix.com> <1389731995-9887-2-git-send-email-zoltan.kiss@citrix.com> <20140116000040.GA5331@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140116000040.GA5331@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16/01/14 00:00, Wei Liu wrote:
> There is a stray blank line change in xenvif_tx_create_gop. (I removed
> that part too early and didn't bother to paste it back...)
Ok, fixed

>> +static inline bool tx_dealloc_work_todo(struct xenvif *vif)
>> +{
>> +	if (vif->dealloc_cons != vif->dealloc_prod)
>> +		return true;
>> +
>> +	return false;
>
> This can be simplified as
>    return vif->dealloc_cons != vif->dealloc_prod;
Indeed, done.
