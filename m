From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Fw: [Bugme-new] [Bug 2133] New: bad: scheduling while atomic!
Date: Wed, 18 Feb 2004 14:22:53 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4033E5BD.9080504@us.ibm.com>
References: <20040218110024.3dee0e42.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Andi Kleen <ak@muc.de>, michal-bugzilla@logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040218110024.3dee0e42.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton rote:

> This is possibly a locking bug in the ipv6 code: someone somewhere
> forgot to undo a lock and the task ended up in atomic state.
> Possibly it is specific to x86_64.
> 
> Has anyone run the TAHI suite on x86?

Yep, we're running TAHI on x86, but haven't seen this.
Not sure we're on 2.6.3 yet, though.

We'll check it out..

thanks,
Nivedita
