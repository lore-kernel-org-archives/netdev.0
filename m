From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [Coverity] Untrusted user data in kernel
Date: Fri, 17 Dec 2004 10:47:37 -0500
Message-ID: <41C2FF99.3020908@tmr.com>
References: <41C26DD1.7070006@trash.net> <Xine.LNX.4.44.0412170144410.12579-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Bryan Fulton <bryan@coverity.com>, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261360AbULQPr7@vger.kernel.org>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0412170144410.12579-100000@thoron.boston.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Fri, 17 Dec 2004, Patrick McHardy wrote:
> 
> 
>>James Morris wrote:
>>
>>
>>>This at least needs CAP_NET_ADMIN.
>>>
>>
>>It is already checked in do_ip6t_set_ctl(). Otherwise anyone could
>>replace iptables rules :)
> 
> 
> That's what I meant, you need the capability to do anything bad :-)

Are you saying that processes with capability don't make mistakes? This 
isn't a bug related to untrusted users doing privileged operations, it's 
a case of using unchecked user data.


-- 
    -bill davidsen (davidsen@tmr.com)
"The secret to procrastination is to put things off until the
  last possible moment - but no longer"  -me
