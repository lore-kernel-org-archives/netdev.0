From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH V3 0/2 net-next] hyperv: Enable batched notification
Date: Tue, 17 Mar 2015 19:26:29 +0000
Message-ID: <BY2PR0301MB0711AB7E8E0432AD57E29908A0030@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <1426608145-14139-1-git-send-email-kys@microsoft.com>
 <20150317.152324.744727347577991569.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>
To: David Miller <davem@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150317.152324.744727347577991569.davem@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@redhat.com]
> Sent: Tuesday, March 17, 2015 12:23 PM
> To: KY Srinivasan
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> jasowang@redhat.com
> Subject: Re: [PATCH V3 0/2 net-next] hyperv: Enable batched notification
> 
> From: "K. Y. Srinivasan" <kys@microsoft.com>
> Date: Tue, 17 Mar 2015 09:02:25 -0700
> 
> > Take into consideration the xmit_more flag in skb to decide if we should
> > notify the host as we place packets in VMBUS.
> >
> > The VMBUS API that would give us this control is already in Greg's tree, in
> this
> > patch-set, that API is exported so it can be used in the netvsc driver. Greg
> has
> > acked this export.
> >
> > In this version of the patch-set, the patch to address the vmbus signalling
> > fix is not included here; that patch will be taken through Greg's tree.
> > I have also gotten rid of an unnecessary local variable in start_xmit()
> > function based on feedback from Jason Wang <jasowang@redhat.com>.
> 
> This patch set does not apply to net-next at all.

I will rebase this and send it.

Thanks,

K. Y
