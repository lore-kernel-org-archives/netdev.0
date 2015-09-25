From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [RFC v2 net-next 05/10] qede: Add basic network device support
Date: Fri, 25 Sep 2015 06:02:39 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63E32AD4@avmb3.qlogic.org>
References: <1442499839-22762-6-git-send-email-Yuval.Mintz@qlogic.com>
	<20150924142536.052d6175@urahara>
	<B5657A6538887040AD3A81F1008BEC63E32A5E@avmb3.qlogic.org>
 <20150924.225637.783498142122739755.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	"Sudarsana Kalluru" <Sudarsana.Kalluru@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:58929 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751746AbbIYGCn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2015 02:02:43 -0400
In-Reply-To: <20150924.225637.783498142122739755.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> > +struct qede_rx_queue {
> >> > +	__le16			*hw_cons_ptr;
> >>
> >> The __ variants of constants should be reserved for use in user
> >> visible API's
> >
> > Really? If so, this needs to be fixed not only here but in lots of
> > places in the series [e.g., entire HW HSI uses __le variants instead of le].
> > But why is it so? I.e., I understand that __le16 is defined in the
> > uapi directory and thus accessible to users, but why the distinction?
> 
> Because it shows whether the type is something exposed to userspace or not.
> 
> If there are places where this is done incorrectly in the tree, it is not a legitimate
> reason for you to do so as well.

Obviously.
We'll fix all of those for next version.
