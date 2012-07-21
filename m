From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v5] sctp: Implement quick failover draft from tsvwg
Date: Sat, 21 Jul 2012 07:03:43 -0400
Message-ID: <20120721110343.GA5128@neilslaptop.think-freely.org>
References: <1342203998-24037-1-git-send-email-nhorman@tuxdriver.com>
 <1342810319-27457-1-git-send-email-nhorman@tuxdriver.com>
 <ab3918ef-84db-413c-93d7-c3b9afe8fa87@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, joe@perches.com
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59590 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724Ab2GULDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2012 07:03:55 -0400
Content-Disposition: inline
In-Reply-To: <ab3918ef-84db-413c-93d7-c3b9afe8fa87@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 21, 2012 at 02:45:03AM -0400, Vlad Yasevich wrote:
> Neil Horman <nhorman@tuxdriver.com> wrote:
><snip>
> >+
> >+		val.spt_pathmaxrxt = trans->pathmaxrxt;
> >+		val.spt_pathpfthld = trans->pf_retrans;
> >+	}
> >+
> >+	if (copy_to_user(optval, &val, optlen))
> >+		return -EFAULT;
> >+
> >+	return optlen;
> 
> I don't think you can simply return this.  You have to call put_user() with the value to write it back to the User.  See how other get calls are done.
> 
> -Vlad
> 
Yeah, sorry, I had assumed that the put_user for the return code was part of the
common sctp_getsockopt path and didn't go check.  Thanks, I'll respin this later
tonight.
Neil
