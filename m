From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next v5 1/9] xen-netback: Introduce TX grant map
 definitions
Date: Mon, 24 Feb 2014 11:13:35 +0000
Message-ID: <1393240415.16570.46.camel@kazak.uk.xensource.com>
References: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>
				 <1390253069-25507-2-git-send-email-zoltan.kiss@citrix.com>
			 <1392743214.23084.38.camel@kazak.uk.xensource.com>
			 <5303C44D.4070500@citrix.com>
		 <1392804319.23084.109.camel@kazak.uk.xensource.com>
		 <53050BF5.1060009@citrix.com>
	 <1392888808.22494.21.camel@kazak.uk.xensource.com>
	 <5306A993.5010504@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5306A993.5010504@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-02-21 at 01:19 +0000, Zoltan Kiss wrote:
> I don't know if the guest expects that slots for the same packet 
> comes back at the same time. 

I don't think the guest is allowed to assume that. In particular they
aren't allowed to assume the the slots will be freed in the order they
were presented on the ring. There used to be a debug patch to
deliberately permute the responses, perhaps it was in the old
netchannel2 tree.

Ian.
