From: Tomas Carnecky <tom@dbservice.com>
Subject: Re: [Coverity] Untrusted user data in kernel
Date: Fri, 17 Dec 2004 14:18:52 +0100
Message-ID: <41C2DCBC.1080302@dbservice.com>
References: <Xine.LNX.4.44.0412170144410.12579-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Bryan Fulton <bryan@coverity.com>, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262801AbULQNQp@vger.kernel.org>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0412170144410.12579-100000@thoron.boston.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> That's what I meant, you need the capability to do anything bad :-)
> 

But.. even if you have the 'permission' to do bad things, it shouldn't 
be possible.

It's a bug, and only because you can't exploit it if you haven't the 
right capabilities doesn't make the bug disappear.

IMHO such things (passing values between user/kernel space) should 
always be checked.

tom
