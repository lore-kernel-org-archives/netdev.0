From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [Prism54] CVS -> bk tree update
Date: Tue, 15 Jun 2004 23:10:28 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <40CFBA24.7030307@pobox.com>
References: <20040614191651.GC6253@ruslug.rutgers.edu>
	<40CE2754.1020109@pobox.com>
	<20040616022008.GM6253@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
	Netdev <netdev@oss.sgi.com>, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: "Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>
In-Reply-To: <20040616022008.GM6253@ruslug.rutgers.edu>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

Luis R. Rodriguez wrote:
> Thanks Jeff. I did, and a diff of Andrew's -mm tree Vs our cvs tree
> 2.6.7-prism54 gives a 1898 line diff. This is excluding spaces,
> newlines, and tabbing and all of Andew's .orig, .rej's. 
> 
> This time it's going to be a *real* pain to provide a changelog and split the
> diffs.. so can I just send you that 1898 line diff and then another for
> space changes? Everything has already been reviewed on the lists here...
> 
> I promise this will be our last big patch too. I'll ask our team
> to send patches from now on to netdev after each ChangeLog entry, for
> more public review and to not loose sync of our trees. Let us know if
> you think we should do otherwise.


Sorry, no.  You knew that split-up patches would be needed, once the 
initial driver merge is complete (which was complete before the most 
recent series of 17 patches).

This is one of the big downsides to developing in CVS, and it bites 
people again and again.

Linux kernel development relies on split-up patches for review, testing, 
  and narrowing down which patch in a series introduced a bug.  There 
are real, engineering-related reasons we do things this way.

	Jeff
