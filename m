From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn/gigaset: Convert timers to use timer_setup()
Date: Thu, 05 Oct 2017 09:53:09 -0700 (PDT)
Message-ID: <20171005.095309.1742522481534840543.davem@davemloft.net>
References: <20171005005212.GA23556@beast>
        <1507190336.2167.5.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: keescook@chromium.org, isdn@linux-pingi.de, johan@kernel.org,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        tglx@linutronix.de, linux-kernel@vger.kernel.org
To: pebolle@tiscali.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507190336.2167.5.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Bolle <pebolle@tiscali.nl>
Date: Thu, 05 Oct 2017 09:58:56 +0200

> Hi Kees,
> 
> On Wed, 2017-10-04 at 17:52 -0700, Kees Cook wrote:
>> Also uses kzmalloc to replace open-coded field assignments to NULL and zero.
> 
> If I'm allowed to whine (chances that I'm allowed to do that are not so great
> as Dave tends to apply gigaset patches before I even have a chance to look at
> them properly!): I'd prefer it if that was done separately in a preceding
> patch. Would that bother you? 

Agreed, these timer transformations are already exhausting to review without
unrelated modifications sneaking in.
