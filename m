From: Andi Kleen <ak@suse.de>
Subject: Re: Fragment ID wrap workaround (read-only, untested).
Date: Thu, 15 Jul 2004 19:02:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040715190249.01a9c11e.ak@suse.de>
References: <20040715182735.3787c8b1.ak@suse.de>
	<OF6D39F992.163676EB-ON88256ED2.005AF110-88256ED2.005CC82F@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, rusty@au1.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF6D39F992.163676EB-ON88256ED2.005AF110-88256ED2.005CC82F@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 15 Jul 2004 09:54:53 -0700
David Stevens <dlstevens@us.ibm.com> wrote:


> I agree that NFS over UDP should be dead as soon as possible,
> and fragmentation in general not far behind it. They aren't quite
> dead yet; until they are, why not make them better behaved? And
> if your argument is that it isn't worth fixing because it isn't

I wouldn't go that far, just make extremly sure that any 
solution works on slow links too. The problem I see 
is that if you make the delay factor long enough to make 
the extremly variable links not regress you risk 
making the wrap on very fast links likely again. 

-Andi
