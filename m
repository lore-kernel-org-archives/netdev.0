From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [RFC v2 net-next 05/10] qede: Add basic network device support
Date: Tue, 29 Sep 2015 07:54:32 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63E351A3@avmb3.qlogic.org>
References: <1442499839-22762-6-git-send-email-Yuval.Mintz@qlogic.com>
	<20150924142536.052d6175@urahara>
	<B5657A6538887040AD3A81F1008BEC63E32A5E@avmb3.qlogic.org>
 <20150924.225637.783498142122739755.davem@davemloft.net>
 <B5657A6538887040AD3A81F1008BEC63E32AD4@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	David Miller <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:24158 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755683AbbI2Hyh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2015 03:54:37 -0400
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63E32AD4@avmb3.qlogic.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > >> > +struct qede_rx_queue {
> > >> > +	__le16			*hw_cons_ptr;
> > >>
> > >> The __ variants of constants should be reserved for use in user
> > >> visible API's
> > >
> > > Really? If so, this needs to be fixed not only here but in lots of
> > > places in the series [e.g., entire HW HSI uses __le variants instead of le].
> > > But why is it so? I.e., I understand that __le16 is defined in the
> > > uapi directory and thus accessible to users, but why the distinction?
> >
> > Because it shows whether the type is something exposed to userspace or not.
> >
> > If there are places where this is done incorrectly in the tree, it is
> > not a legitimate reason for you to do so as well.
> 
> Obviously.
> We'll fix all of those for next version.

I've taken a look and I couldn't find reference to 'le16' anywhere under
drivers/net/ethernet/. And 'le16' is actually a fs/ntfs/types.h definition.

What am I missing here?
