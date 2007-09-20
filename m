From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: Pull request for 'r8169-for-jeff-20070919' branch
Date: Thu, 20 Sep 2007 17:26:40 -0400
Message-ID: <46F2E590.1070704@redhat.com>
References: <20070919195606.GA3871@electric-eye.fr.zoreil.com> <46F2D24A.6050200@redhat.com> <20070920204437.GB13512@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, David Gundersen <gundy@iinet.net.au>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Sylvain Le Gall <sylvain@le-gall.net>,
	Roel.Teuwen@advalvas.be
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56135 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751493AbXITV1c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 17:27:32 -0400
In-Reply-To: <20070920204437.GB13512@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/20/2007 04:44 PM, Francois Romieu wrote:
> Chuck Ebbert <cebbert@redhat.com> :
> [...]
>> People are still reporting hangs with this card in 2.6.22.6, are there
>> any fixes appropriate for that?
> 
> $ grep 2.6.22.6 ~/Mail/linux/bugs/pending
> $ grep 2.6.22.6 ~/Mail/romieu
> [nothing besides Sylvain's success with 2.6.22.6 + the r8169 test driver]
> $ less +/2.6.22.6 ~/Mail/linux/netdev/200709 
> [nada]
> $ less +/816[89] ~/Mail/linux/kernel/200737
> [...]
> 
> /me scratches head...
> 
> The answer is probably "not yet".
> 
> Can you refresh my memory with some #BZ or an url ?
> 

Looking again, it may not be r8169's fault, but it is involved. It
used to hang and could be restarted by pulling the cable and reinserting
it, but now it just locks solid:

https://bugzilla.redhat.com/show_bug.cgi?id=252955

Will ask the reporter to test with a different adapter.

