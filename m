From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH net-next v2] net: clean up locking in inet_frag_find()
Date: Mon, 26 Nov 2012 14:42:31 +0100
Message-ID: <1353937351.11754.207.camel@localhost>
References: <1353909184.11282.3.camel@cr0>
	 <1353914786-10426-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Cong Wang <amwang@redhat.com>, David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27977 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753975Ab2KZNme (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2012 08:42:34 -0500
In-Reply-To: <1353914786-10426-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Could we please hold back on this cleanup patch, as I have a stack of 9
patches modifying this area.

If people find this cleanup useful/correct?, I can integrate it into my
patch stack...

--Jesper

On Mon, 2012-11-26 at 15:26 +0800, Cong Wang wrote:
> It is weird to take the read lock outside of inet_frag_find()
> but release it inside...  This can be improved by refactoring
> the code, that is, introducing inet{4,6}_frag_find() which call
> the their own hash function, inet{4,6}_hash_frag(), hiding the
> details from their callers.
