From: Keith Owens <kaos@ocs.com.au>
Subject: Re: [PATCH] udp: Introduce special NULL pointers for hlist termination
Date: Fri, 31 Oct 2008 11:14:27 +1100
Message-ID: <8186.1225412067@ocs10w>
References: <4909D551.9080309@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com, Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ocs.com.au ([202.134.241.204]:28195 "EHLO mail.ocs.com.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752955AbYJaAXl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2008 20:23:41 -0400
In-reply-to: Your message of "Thu, 30 Oct 2008 16:40:01 BST."
             <4909D551.9080309@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet (on Thu, 30 Oct 2008 16:40:01 +0100) wrote:
>+/**
>+ * ptr_is_a_nulls - Test if a ptr to struct hlist_nulls_node is a nulls

Typo: comment says 'ptr_is_a_nulls' but function is called 'is_a_nulls'.

>+ * @ptr: ptr to be tested
>+ *
>+ */
>+static inline int is_a_nulls(struct hlist_nulls_node *ptr)
>+{
>+	return ((unsigned long)ptr & 1);
>+}

