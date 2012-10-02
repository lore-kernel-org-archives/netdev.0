From: Julian Anastasov <ja@ssi.bg>
Subject: Re: network namespace and kernel bind issue
Date: Tue, 2 Oct 2012 09:15:46 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1210020910010.1642@ja.ssi.bg>
References: <20121001141609.14639bc0@nehalam.linuxnetplumber.net> <20121001145838.5eafef4c@nehalam.linuxnetplumber.net> <87fw5xeryf.fsf@xmission.com> <20121001155702.5b5e2188@nehalam.linuxnetplumber.net> <87y5jpdbzo.fsf@xmission.com>
 <20121001163226.3873ca58@nehalam.linuxnetplumber.net> <871uhhd82p.fsf@xmission.com> <20121001174841.41fcd637@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:43229 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753222Ab2JBGKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2012 02:10:43 -0400
In-Reply-To: <20121001174841.41fcd637@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 1 Oct 2012, Stephen Hemminger wrote:

> The problem was vxlan wasn't doing sk_change_net on the created socket.
> 
> I'm testing that fix.
> 
> The long term fix is to change sock_create_kern() to take a 'struct net'
> argument. This would avoid the trap of having to change the namespace.
> Also several places using __sock_create() could use it.
> 
> L2TP still looks to have several namespace related issues.

	There should be also .netnsok = true in l2tp_nl_family
as final step.

Regards

--
Julian Anastasov <ja@ssi.bg>
