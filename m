From: Muli Ben-Yehuda <muli@il.ibm.com>
Subject: Re: attach additional value to skb
Date: Tue, 23 Oct 2007 07:42:14 +0200
Message-ID: <20071023054214.GI5708@rhun.ibm.com>
References: <f36b08ee0710221303y5a846a27v1ebdc919db0f00ac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Yakov Lerner <iler.ml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:25582 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbXJWFm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 01:42:26 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l9N5gPaa283276
	for <netdev@vger.kernel.org>; Tue, 23 Oct 2007 05:42:25 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9N5gOA92003074
	for <netdev@vger.kernel.org>; Tue, 23 Oct 2007 06:42:24 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9N5gIjk015088
	for <netdev@vger.kernel.org>; Tue, 23 Oct 2007 06:42:18 +0100
Content-Disposition: inline
In-Reply-To: <f36b08ee0710221303y5a846a27v1ebdc919db0f00ac@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 22, 2007 at 10:03:47PM +0200, Yakov Lerner wrote:

> I want to add my custom destructor to the skb, the function pointer
> to be called at skb destruction time. Will the following work: if I
> push address of my_destructor to the
> sk-buff->destructor field,  and then when my_destructor
> is called, I call the (saved)  old value of  sk-buff->destructor ?
> Will this work ?

It might, provided nothing else runs after you that will unilaterally
change the ->destructor field. I.e., it depends at which point in the
skb's life-time you set your hook.

Cheers,
Muli
-- 
SYSTOR 2007 --- 1st Annual Haifa Systems and Storage Conference 2007
http://www.haifa.il.ibm.com/Workshops/systor2007/

Virtualization workshop: Oct 29th, 2007 | Storage workshop: Oct 30th, 2007
