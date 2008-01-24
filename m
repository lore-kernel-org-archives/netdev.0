From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH net-2.6.25] Add packet filtering based on process's security context.
Date: Thu, 24 Jan 2008 10:03:54 -0500
Message-ID: <200801241003.54621.paul.moore@hp.com>
References: <200801230016.EGG34399.QFtVHFSJFMOOLO@I-love.SAKURA.ne.jp> <200801242047.JEI35479.OJLFHMtOOFQFVS@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-security-module@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200801242047.JEI35479.OJLFHMtOOFQFVS@I-love.SAKURA.ne.jp>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 24 January 2008 6:47:55 am Tetsuo Handa wrote:
> Are there any remaining questions/problems about this patch?
> If none, I want this patch applied to net-2.6.25 tree.

Hello,

Taking into consideration that there are no current in-tree users of 
this patch and the only known user of this functionality is TOMOYO, 
which is still dealing with some unresolved VFS issues, I suggest not 
merging this patch at the current time.  My recommendation is to 
continue to work on resolving the VFS issues (which it appears you are 
working on) and then submitting all of the required TOMOYO changes at 
once.

As a general rule, removing functionality from the kernel tends to be 
much more difficult then adding it.

-- 
paul moore
linux security @ hp
