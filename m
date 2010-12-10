From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [PATCH] kptr_restrict for hiding kernel pointers from
 unprivileged users
Date: Thu, 09 Dec 2010 21:45:18 -0500
Message-ID: <1291949118.1877.2.camel@dan>
References: <1291863926.2965.1.camel@Dan>
	 <1291865039.2795.46.camel@edumazet-laptop>  <1291895472.2965.4.camel@Dan>
	 <1291898801.2965.6.camel@Dan>  <1291901420.4063.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1291901420.4063.24.camel@edumazet-laptop>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
> Well, it seems difficult to make a check here, its a generic function
> that happens to be used from different contexts.
> 
> Even using in_irq() might be a problem.

I agree it seems difficult - my only goal was to prevent subsequent
breakage with the capability check.  Does anyone have any suggestions
for a better approach here?

-Dan

