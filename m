From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Fri, 08 Aug 2008 18:20:01 -0400
Message-ID: <489CC691.6090905@garzik.org>
References: <200807300019.m6U0JkdY012558@localhost.localdomain> <aday73jxdfs.fsf@cisco.com> <200807311752.00911.divy@chelsio.com> <200808071145.03848.divy@chelsio.com> <489C8BEB.8060001@opengridcomputing.com> <489CC58D.4010606@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Divy Le Ray <divy@chelsio.com>, Roland Dreier <rdreier@cisco.com>,
	Karen Xie <kxie@chelsio.com>, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, michaelc@cs.wisc.edu,
	daisyc@us.ibm.com, wenxiong@us.ibm.com, bhua@us.ibm.com,
	Dimitrios Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Steve Wise <swise@opengridcomputing.com>, davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <489CC58D.4010606@pobox.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> * however, giving the user the ability to co-manage IP addresses means 
> hacking up the kernel TCP code and userland tools for this new concept, 
> something that I think DaveM would rightly be a bit reluctant to do? You 
> are essentially adding a bunch of special case code whenever TCP ports 
> are used:
> 
>     if (port in list of "magic" TCP ports with special,
>         hardware-specific behavior)
>         ...
>     else
>         do what we've been doing for decades
> 
> ISTR Roland(?) pointing out code that already does a bit of this in the 
> IB space...  but the point is

grrr.   but the point is that the solution is not at all complete, with 
feature disconnects and security audit differences still outsanding, and 
non-hw-specific management apps still unwritten.

(I'm not calling for their existence, merely saying trying to strike the 
justification that current capability to limp along exists)

	Jeff


