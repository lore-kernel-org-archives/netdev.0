From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFD] iptables:  mangle table obsoletes filter table
Date: Fri, 12 Oct 2007 06:39:48 +0200
Message-ID: <470EFA94.2090706@trash.net>
References: <200710120031.42805.a1426z@gawab.com> <470EF994.4080403@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Al Boldi <a1426z@gawab.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <470EF994.4080403@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Please send mails discussing netfilter to netfilter-devel.

Correct address CCed and unrelated lists removed .. stupid
auto-completion :)

> Al Boldi wrote:
> 
>>With the existence of the mangle table, how useful is the filter table?
>>
>>Other than requiring the REJECT target to be ported to the mangle table, is 
>>the filter table faster than the mangle table?
> 
> 
> There are some minor differences in ordering (mangle comes before
> DNAT, filter afterwards), but for most rulesets thats completely
> irrelevant. The only difference that really matters is that mangle
> performs rerouting in LOCAL_OUT for packets that had their routing
> key changed, so its really a superset of the filter table. If you
> want to use REJECT in the mangle table, you just need to remove the
> restriction to filter, it works fine. I would prefer to also remove
> the restriction of MARK, CONNMARK etc. to mangle, they're used for
> more than just routing today so that restriction also doesn't make
> much sense. Patches for this are welcome.
> 
> 
>>If not, then shouldn't the filter table be obsoleted to avoid confusion?
> 
> 
> That would probably confuse people. Just don't use it if you don't
> need to.
