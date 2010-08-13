From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PATCH v2 0/3] cxgbi iscsi driver
Date: Fri, 13 Aug 2010 11:32:06 -0500
Message-ID: <4C657386.6050308@cs.wisc.edu>
References: <201008131519.o7DFJsaH002618@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com, rranjan@chelsio.com,
	James.Bottomley@HansenPartnership.com, davem@davemloft.net
To: kxie@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <201008131519.o7DFJsaH002618@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/13/2010 10:19 AM, kxie@chelsio.com wrote:
> [PATCH v2 0/3] cxgbi iscsi driver
>
> From: Karen Xie<kxie@chelsio.com>
>
> Re-submission, missed netdev list last time.
>
> This patchset includes:
>
> 1. added libcxgbi as the common library for both cxgb4i and cxgb3i driver
> 2. added cxgb4i iscsi initiator v5.
> 3. changed cxgb3i to use libcxgbi.
>
> The version 2 includes the following changes:
> - Made dbg_level static to avoid compiling errors when both cxgb3i and cxgb4i
>    are built into the kernel.
> - Deleted cxgbi_fill_iscsi_transport() and cxgbi_fill_scsi_host_template().
>    The iscsi_transport and scsi_host_template are initialized in the drivers
>    instead of being filled in by the library at runtime..
> - Only register with iscsi class transport once per driver type.
>

iSCSI and SCSI parts look ok now. The network code should be reviewed by 
the netdev people, because I am not qualified to review that. Thanks for 
your work Karen.

Reviewed-by: Mike Christie <michaelc@cs.wisc.edu>
